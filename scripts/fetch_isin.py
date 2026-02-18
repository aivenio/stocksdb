# -*- encoding: utf-8 -*-

"""
A Script to Fetch and Update ISIN Data from NSDL Website

National Securities Depository Limited (NSDL) provides a list of ISIN
codes of all companies registered with NSDL. Another alternate is the
CDSL (Central Securities Depository Limited) exchange. Information
is available at https://nsdl.co.in/master_search.php.
"""

import os

from tqdm import tqdm as TQ

import pandas as pd
import sqlalchemy as sa

def fetch_isin(
        url : str,
        columns : tuple,
        verbose : bool = True,
        security_issuer_type_column : str = "security_issuer_type",
        drop_security_status : bool = True,
        security_status_column : str = "current_status",
        primary_key_column : str = "security_isin_code"
    ) -> pd.DataFrame:
    """
    A function to fetch the ISIN data listed under the National
    Securities Depository Limited (NSDL) which is available in the
    public domain. However, the script tries to fetch the data from
    India ISIN Database (by Nemo) which scraps the data from the NSDL
    website. Check the readme file for more details.
    
    :type  url: str
    :param url: The URL to fetch the ISIN data, currently, this is
        a static value, but it may change in the future.

    :type  columns: tuple
    :param columns: The column names for the dataframe, which should
        be the final value as in the database schema design.

    :type  verbose: bool
    :param verbose: A flag to print the information about the
        dataframe, default is True.

    :type security_issuer_type_column: str
    :param security_issuer_type_column: Name of the column (if
        present) which contains the security issuer type.

    :type  drop_security_status: bool
    :param drop_security_status: Drop the security status column
        (if present), default is True.

    :type  security_status_column: str
    :param security_status_column: Name of the column (if present)
        which contains the security status, default is
        "current_status". The value must be present if 
        `drop_security_status` is True, else key error is raised.

    :type  primary_key_column: str
    :param primary_key_column: Name of the column (if present)
        which contains the primary key, default "security_isin_code".
        An assertion check is done to find duplicate values.
    """

    data = pd.read_csv(
        url, skiprows = 1, header = None, names = columns, dtype = str
    )

    if verbose:
        print(f"Fetched {data.shape[0]:,} Record(s) from {url}")

    for column in TQ(data.columns, desc = "Normalizing Values"):
        data[column] = data[column].apply(
            lambda x : x.strip().upper() if not pd.isna(x) else None
        )
    
    # ! Normalize Security Issuer Type [CONSTANT]; Check ENUM
    normalized_issuer_type = {
        "EQUITY SHARES" : "EQUITY SHARES (EQ)",
        "GOVERNMENT SECURITIES" : "GOVERNMENT SECURITIES (G-SEC)",
        "REAL ESTATE INVESTMENT TRUSTS" : "REAL ESTATE INVESTMENT TRUSTS (REIT)",
        "SOVEREIGN GOLD BOND" : "SOVEREIGN GOLD BOND (SGB)",
    }

    data[security_issuer_type_column] = data[security_issuer_type_column].apply(
        lambda x : normalized_issuer_type.get(x, x)
    )

    if drop_security_status:
        data.drop(columns = [security_status_column], inplace = True)
    
    # ! Assert data quality, raises assertion error on fail
    assert data[primary_key_column].nunique() == data.shape[0], \
        f"Primary key {primary_key_column} cannot have a duplicate value."
    
    # ? add data source information
    data["isin_data_source_id"] = "ISIN0"

    return data


if __name__ == "__main__":
    URI = "https://raw.githubusercontent.com/captn3m0/india-isin-data/refs/heads/main/ISIN.csv"
    data = fetch_isin(
        URI,
        columns = (
            "security_isin_code",
            "security_description",
            "security_issuer_name",
            "security_issuer_type",
            "current_status"
        )
    )

    # get configurations for database connection elements, and build
    DATABASE = os.environ["AIVENIO_STOCKSDB_DATABASE"]
    HOSTNAME = os.environ["AIVENIO_STOCKSDB_HOSTNAME"]
    PASSWORD = os.environ["AIVENIO_STOCKSDB_PASSWORD"]
    PORTNAME = os.environ["AIVENIO_STOCKSDB_PORTNAME"]
    USERNAME = os.environ["AIVENIO_STOCKSDB_USERNAME"]

    engine = sa.create_engine(
        f"postgresql+psycopg://{USERNAME}:{PASSWORD}@{HOSTNAME}:{PORTNAME}/{DATABASE}"
    )

    try:
        engine.connect()
    except Exception as err:
        raise ValueError("Host is not reachable.")

    with engine.connect() as connection:
        metadata = sa.Table(
            "securities_mw", sa.MetaData(schema = "common"),
            autoload_with = connection
        )

        connection.execute(metadata.insert(), data.to_dict(orient = "records"))
        connection.commit()
