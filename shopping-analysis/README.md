# Data Engineering Assignments

# Assignment 1 - Shopping Dataset Analysis

## Overview

This project is the first assignment in the Data Engineering assignment series. The objective was to learn Python basics, perform exploratory data analysis (EDA), clean a dataset using Pandas, create derived features, and generate visual insights.

The analysis was performed on a shopping dataset containing product information such as prices, ratings, discounts, and categories.

## Dataset

- Dataset: Shopping Dataset
- Records: 1000 products
- Attributes: 24 columns

## Tasks Performed

### Data Exploration

- Loaded the CSV dataset into a Pandas DataFrame.
- Examined dataset shape, columns, data types, and summary statistics.
- Identified missing values and duplicate records.

### Data Cleaning

- Converted price-related columns from string format to numeric format.
- Handled missing values in price columns using median imputation.
- Replaced missing discount values with 0.
- Checked and removed duplicate records when necessary.

### Feature Engineering

Created the following derived features:

- **Final Price**: Calculated by applying the discount to the initial price.
- **Price Difference**: Difference between initial price and final price.
- **Popularity Metric**: Calculated using rating and ratings count.

### Data Analysis

Performed:

- Filtering of highly rated products.
- Column selection and data extraction.
- Category-level analysis.
- Price distribution analysis.

### Visualizations

Generated:

- Rating Distribution Histogram
- Category Distribution Bar Chart
- Final Price Boxplot

## Key Insights

1. The dataset contains 1000 products with 24 attributes.
2. Missing values of prices were handled using median imputation.
3. Missing values of discount were replaced with 0.
4. No duplicate records were found, though duplicate-removal logic was implemented.
5. Price columns were converted from string format to numeric format.
6. Final prices were recalculated using the available discount values.
7. Price difference and popularity metrics were created for analysis.
8. Product ratings are concentrated in the higher rating range, with most ratings between 4.0 and 4.5.
9. Tops is the most common product category in the dataset.
10. Most product prices lie between ₹200 and ₹3000, with a median around ₹900–₹1000. Several high-priced outliers extend up to approximately ₹17,000.

## Technologies Used

- Python
- Pandas
- NumPy
- Matplotlib
- Jupyter Notebook

## Project Structure

```text
assignment1-shopping-analysis/
│
├── data/
│   ├── combined_dataset.csv
│   └── cleaned_dataset.csv
│
├── notebook/
│   └── assg1.ipynb
│
└── README.md
```
