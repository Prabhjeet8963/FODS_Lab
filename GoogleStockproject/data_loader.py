import pandas as pd

def load_and_clean_data(file_path):
    """
    Load historical Google stock dataset, rename columns, sort chronologically,
    and drop missing values.
    """
    df = pd.read_csv(file_path)
    
    # Rename columns to match standard format
    rename_map = {
        'date': 'Date',
        '1. open': 'Open',
        '2. high': 'High',
        '3. low': 'Low',
        '4. close': 'Close',
        '5. volume': 'Volume'
    }
    df.rename(columns=rename_map, inplace=True)
    
    # Convert 'Date' to datetime and sort chronologically (no random shuffle)
    df['Date'] = pd.to_datetime(df['Date'])
    df.sort_values('Date', ascending=True, inplace=True)
    df.reset_index(drop=True, inplace=True)
    
    # Handle missing values by dropping NaNs
    df.dropna(inplace=True)
    
    return df
