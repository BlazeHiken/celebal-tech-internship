# Azure Cloud Fundamentals and Data Pipeline using Azure Data Factory

## Objective

To understand Azure cloud concepts and build an end-to-end data pipeline using Azure Storage Account and Azure Data Factory.

## Services Used

- Azure Resource Group
- Azure Storage Account
- Azure Blob Storage
- Azure Data Factory
- IAM (Access Control)

## Tasks Completed

- Created a Resource Group.
- Created a Storage Account.
- Created a Blob Container.
- Uploaded the Superstore CSV file.
- Created Azure Data Factory.
- Configured Blob Storage Linked Service.
- Created Source and Destination datasets.
- Implemented Get Metadata activity.
- Implemented Copy Data activity.
- Executed the pipeline successfully.
- Validated metadata output.
- Copied the CSV file to the destination container.
- Assigned Reader and Contributor roles to the Azure Data Factory managed identity.

## Pipeline Architecture

Blob Storage (Source)
↓
Get Metadata
↓
Copy Data
↓
Blob Storage (Destination)

## Result

The pipeline executed successfully. The metadata was retrieved, and the CSV file was copied from the source container to the destination container.

## Screenshots

All screenshots are available in the `screenshots` folder.