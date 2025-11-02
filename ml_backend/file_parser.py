import pandas as pd
import csv
import json
from io import StringIO, BytesIO
import PyPDF2

class FileParser:
    """Parse CSV, Excel, PDF files for water quality data"""
    
    @staticmethod
    def parse_csv(content):
        """Parse CSV content"""
        try:
            df = pd.read_csv(StringIO(content))
            return df
        except Exception as e:
            raise Exception(f"CSV parsing error: {str(e)}")
    
    @staticmethod
    def parse_excel(file_bytes):
        """Parse Excel file"""
        try:
            df = pd.read_excel(BytesIO(file_bytes))
            return df
        except Exception as e:
            raise Exception(f"Excel parsing error: {str(e)}")
    
    @staticmethod
    def parse_pdf(file_bytes):
        """Extract tables from PDF"""
        try:
            tables = []
            pdf_reader = PyPDF2.PdfReader(BytesIO(file_bytes))
            
            for page_num, page in enumerate(pdf_reader.pages):
                text = page.extract_text()
                tables.append({'page': page_num + 1, 'text': text})
            
            return tables
        except Exception as e:
            raise Exception(f"PDF parsing error: {str(e)}")
    
    @staticmethod
    def convert_to_dataframe(data):
        """Convert dict or list to DataFrame"""
        try:
            if isinstance(data, dict):
                # If it's a dict with lists as values
                df = pd.DataFrame(data)
            elif isinstance(data, list):
                # If it's a list of dicts
                df = pd.DataFrame(data)
            elif isinstance(data, pd.DataFrame):
                df = data
            else:
                raise ValueError(f"Unsupported data type: {type(data)}")
            
            return df
        except Exception as e:
            raise Exception(f"DataFrame conversion error: {str(e)}")
    
    @staticmethod
    def extract_water_data(df):
        """Extract water quality columns from DataFrame"""
        water_columns = {
            'pH': ['pH', 'ph', 'PH'],
            'turbidity': ['turbidity', 'Turbidity', 'TURBIDITY', 'turb'],
            'dissolved_oxygen': ['dissolved_oxygen', 'DissolvedOxygen', 'do', 'DO', 'oxygen'],
            'temperature': ['temperature', 'Temperature', 'temp', 'Temp', 'temperature_c'],
            'conductivity': ['conductivity', 'Conductivity', 'cond', 'Conductivity'],
            'location': ['location', 'Location', 'zone', 'Zone'],
            'timestamp': ['timestamp', 'date', 'Date', 'time', 'Time'],
        }
        
        extracted = {}
        
        for key, aliases in water_columns.items():
            for col in df.columns:
                if col in aliases:
                    extracted[key] = df[col]
                    break
                elif col.lower() in [a.lower() for a in aliases]:
                    extracted[key] = df[col]
                    break
        
        return extracted
    
    @staticmethod
    def analyze_file_statistics(data):
        """Generate statistics from file data"""
        try:
            # Convert to DataFrame if needed
            if not isinstance(data, pd.DataFrame):
                df = FileParser.convert_to_dataframe(data)
            else:
                df = data
            
            print(f"DataFrame shape: {df.shape}")
            print(f"DataFrame columns: {df.columns.tolist()}")
            
            water_data = FileParser.extract_water_data(df)
            
            print(f"Extracted water data keys: {water_data.keys()}")
            
            stats = {}
            for col, data_series in water_data.items():
                if col not in ['location', 'timestamp']:
                    try:
                        # Convert to numeric
                        numeric_data = pd.to_numeric(data_series, errors='coerce')
                        stats[col] = {
                            'mean': float(numeric_data.mean()),
                            'min': float(numeric_data.min()),
                            'max': float(numeric_data.max()),
                            'std': float(numeric_data.std()),
                        }
                    except Exception as e:
                        print(f"Error processing {col}: {e}")
            
            return stats, water_data
        except Exception as e:
            raise Exception(f"Statistics calculation error: {str(e)}")
