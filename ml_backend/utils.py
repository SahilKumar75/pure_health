"""
Utility functions for AI analysis services
"""

import numpy as np
import pandas as pd
from typing import Any, Dict, List
import json


def convert_to_serializable(obj: Any) -> Any:
    """
    Convert numpy/pandas types to JSON-serializable Python types
    
    Args:
        obj: Object to convert (can be nested dict/list)
        
    Returns:
        JSON-serializable version of the object
    """
    if isinstance(obj, (np.integer, np.int64, np.int32, np.int16, np.int8)):
        return int(obj)
    elif isinstance(obj, (np.floating, np.float64, np.float32, np.float16)):
        return float(obj)
    elif isinstance(obj, np.bool_):
        return bool(obj)
    elif isinstance(obj, np.ndarray):
        return obj.tolist()
    elif isinstance(obj, pd.Series):
        return obj.tolist()
    elif isinstance(obj, pd.DataFrame):
        return obj.to_dict('records')
    elif isinstance(obj, dict):
        return {key: convert_to_serializable(value) for key, value in obj.items()}
    elif isinstance(obj, (list, tuple)):
        return [convert_to_serializable(item) for item in obj]
    elif pd.isna(obj):
        return None
    else:
        return obj


def safe_json_dumps(obj: Any) -> str:
    """
    Safely serialize object to JSON, converting numpy types
    
    Args:
        obj: Object to serialize
        
    Returns:
        JSON string
    """
    serializable_obj = convert_to_serializable(obj)
    return json.dumps(serializable_obj, indent=2)
