import pandas as pd
from dotenv import load_dotenv
import os

load_dotenv()

# Read the CSV
df = pd.read_csv(os.getenv("CSV_PATH_SUPERSTORE_ORIG"), encoding="latin1")

# Convert date columns
df["Order Date"] = pd.to_datetime(
    df["Order Date"], format="%m/%d/%Y"
).dt.strftime("%Y-%m-%d")

df["Ship Date"] = pd.to_datetime(
    df["Ship Date"], format="%m/%d/%Y"
).dt.strftime("%Y-%m-%d")

# Save the converted CSV
df.to_csv(os.getenv("CSV_PATH_SUPERSTORE"), index=False)

print("Date conversion completed successfully!")