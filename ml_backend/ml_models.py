import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from joblib import dump, load
import os

class WaterQualityMLModels:
    def __init__(self):
        self.classifier = None  # Quality status classifier
        self.regressor = None   # Quality score regressor
        self.scaler = StandardScaler()
        self.feature_names = ['pH', 'turbidity', 'dissolved_oxygen', 'temperature', 'conductivity']
        self.model_dir = 'models'
        
        # Create models directory
        os.makedirs(self.model_dir, exist_ok=True)
    
    def train(self, df):
        """
        Train ML models on water quality data
        """
        print("🤖 Training ML Models...")
        
        # Prepare features
        X = df[self.feature_names].values
        
        # Split data
        X_train, X_test = train_test_split(X, test_size=0.2, random_state=42)
        
        # Scale features
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        # Train classifier (status: Safe, Warning, Critical)
        y_status_train = df.loc[X_train.index if hasattr(X_train, 'index') else range(len(X_train)), 'quality_status'].values
        # ... fix indexing
        y_status = df['quality_status'].values
        y_status_train = y_status[:len(X_train)]
        y_status_test = y_status[len(X_train):]
        
        print("  📊 Training Status Classifier...")
        self.classifier = RandomForestClassifier(
            n_estimators=100,
            max_depth=10,
            random_state=42,
            n_jobs=-1
        )
        self.classifier.fit(X_train_scaled, y_status_train)
        
        # Evaluate classifier
        train_score = self.classifier.score(X_train_scaled, y_status_train)
        test_score = self.classifier.score(X_test_scaled, y_status_test)
        print(f"     ✅ Train Accuracy: {train_score:.4f}")
        print(f"     ✅ Test Accuracy: {test_score:.4f}")
        
        # Train regressor (quality score)
        y_score_train = df.loc[:len(X_train)-1, 'quality_score'].values
        y_score_test = df.loc[len(X_train):, 'quality_score'].values
        
        print("  📊 Training Score Regressor...")
        self.regressor = RandomForestRegressor(
            n_estimators=100,
            max_depth=10,
            random_state=42,
            n_jobs=-1
        )
        self.regressor.fit(X_train_scaled, y_score_train)
        
        # Evaluate regressor
        train_r2 = self.regressor.score(X_train_scaled, y_score_train)
        test_r2 = self.regressor.score(X_test_scaled, y_score_test)
        print(f"     ✅ Train R² Score: {train_r2:.4f}")
        print(f"     ✅ Test R² Score: {test_r2:.4f}")
        
        # Save models
        self.save_models()
        print("✅ Models trained and saved!\n")
    
    def save_models(self):
        """Save trained models to disk"""
        dump(self.classifier, os.path.join(self.model_dir, 'classifier.pkl'))
        dump(self.regressor, os.path.join(self.model_dir, 'regressor.pkl'))
        dump(self.scaler, os.path.join(self.model_dir, 'scaler.pkl'))
        print("💾 Models saved to disk")
    
    def load_models(self):
        """Load trained models from disk"""
        try:
            self.classifier = load(os.path.join(self.model_dir, 'classifier.pkl'))
            self.regressor = load(os.path.join(self.model_dir, 'regressor.pkl'))
            self.scaler = load(os.path.join(self.model_dir, 'scaler.pkl'))
            print("✅ Models loaded successfully")
            return True
        except:
            print("❌ Models not found, need to train first")
            return False
    
    def predict(self, pH, turbidity, dissolved_oxygen, temperature, conductivity):
        """
        Make prediction for water quality
        
        Returns:
            status: 'Safe', 'Warning', or 'Critical'
            score: 0-100 quality score
            confidence: Model confidence 0-1
        """
        if self.classifier is None or self.regressor is None:
            raise Exception("Models not trained or loaded")
        
        # Prepare input
        features = np.array([[pH, turbidity, dissolved_oxygen, temperature, conductivity]])
        features_scaled = self.scaler.transform(features)
        
        # Get status prediction
        status = self.classifier.predict(features_scaled)[0]
        status_proba = self.classifier.predict_proba(features_scaled)[0]
        confidence = np.max(status_proba)
        
        # Get score prediction
        score = self.regressor.predict(features_scaled)[0]
        score = max(0, min(100, score))  # Clip to 0-100
        
        # Get feature importance
        recommendations = self._get_recommendations(
            pH, turbidity, dissolved_oxygen, temperature, conductivity
        )
        
        return {
            'status': status,
            'score': float(score),
            'confidence': float(confidence),
            'recommendations': recommendations
        }
    
    def _get_recommendations(self, pH, turbidity, DO, temp, cond):
        """Generate recommendations based on parameters"""
        recs = []
        
        # pH recommendations
        if pH < 6.5:
            recs.append("pH too low. Add alkali treatment.")
        elif pH > 8.5:
            recs.append("pH too high. Add acid treatment.")
        else:
            recs.append("pH level is optimal.")
        
        # Turbidity recommendations
        if turbidity > 5:
            recs.append("High turbidity. Increase filtration.")
        else:
            recs.append("Turbidity levels acceptable.")
        
        # Dissolved Oxygen
        if DO < 5:
            recs.append("Low oxygen. Increase aeration.")
        else:
            recs.append("Dissolved oxygen sufficient.")
        
        # Temperature
        if temp > 30:
            recs.append("Temperature high. Cool the water.")
        elif temp < 10:
            recs.append("Temperature low. Heat if needed.")
        else:
            recs.append("Temperature optimal.")
        
        # Conductivity
        if cond > 600:
            recs.append("High conductivity. Reduce dissolved solids.")
        elif cond < 300:
            recs.append("Low conductivity. May need mineral addition.")
        else:
            recs.append("Conductivity normal.")
        
        return recs
    
    def get_feature_importance(self):
        """Get feature importance from models"""
        if self.classifier is None:
            return None
        
        importance = self.classifier.feature_importances_
        return {
            feature: float(imp) 
            for feature, imp in zip(self.feature_names, importance)
        }

# Training script
if __name__ == '__main__':
    from data_generator import generate_training_data
    
    # Generate data
    print("📊 Generating training data...")
    df = generate_training_data(1000)
    
    # Train models
    models = WaterQualityMLModels()
    models.train(df)
    
    # Test prediction
    print("🧪 Testing predictions...")
    test_cases = [
        (7.0, 2.0, 8.5, 25.0, 500.0),  # Should be Safe
        (6.0, 4.0, 6.0, 28.0, 550.0),  # Should be Warning
        (5.0, 9.0, 2.0, 35.0, 700.0),  # Should be Critical
    ]
    
    for pH, turb, DO, temp, cond in test_cases:
        result = models.predict(pH, turb, DO, temp, cond)
        print(f"\n  pH: {pH}, Turbidity: {turb}, DO: {DO}, Temp: {temp}, Cond: {cond}")
        print(f"    Status: {result['status']}")
        print(f"    Score: {result['score']:.1f}/100")
        print(f"    Confidence: {result['confidence']:.2%}")
