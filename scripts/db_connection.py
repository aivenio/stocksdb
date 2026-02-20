# -*- encoding: utf-8 -*-

"""
A Set of Function(s) for Database Interaction and Management

The function can be used by all the subsequent scripts thus providing
only one controling point to the database.
"""

import os

import pandas as pd
import sqlalchemy as sa

def create_engine(
        database = os.environ["AIVENIO_STOCKSDB_DATABASE"],
        hostname = os.environ["AIVENIO_STOCKSDB_HOSTNAME"],
        password = os.environ["AIVENIO_STOCKSDB_PASSWORD"],
        portname = os.environ["AIVENIO_STOCKSDB_PORTNAME"],
        username = os.environ["AIVENIO_STOCKSDB_USERNAME"]
    ):
    """
    Create a Database Connection Engine using SQLAlchemy
    """

    engine = sa.create_engine(
        f"postgresql+psycopg://{username}:{password}@{hostname}:{portname}/{database}"
    )

    try:
        engine.connect()
    except Exception as err:
        raise ValueError("Host is not reachable.")

    return engine


def insert_data(
        engine : sa.Engine,
        data : pd.Dataframe,
        table : str,
        schema : str = "public"
    ) -> None:
    """
    Insert Data into a Database Table using SQLAlchemy Engine
    """

    with engine.connect() as connection:
        metadata = sa.Table(
            table, sa.MetaData(schema = schema),
            autoload_with = connection
        )

        connection.execute(
            metadata.insert(), data.to_dict(orient = "records")
        )
        connection.commit()

    return
