import streamlit as st
import pandas as pd
import yfinance as yf
import plotly.graph_objects as go
import joblib
from datetime import datetime, timedelta
import matplotlib.pyplot as plt
from sklearn.metrics import confusion_matrix, roc_curve
import shap
import sqlite3
import numpy as np

# ================================
# DESIGN SYSTEM & CUSTOM CSS
# ================================
st.set_page_config(page_title="Google Stock Predictor MLOps", layout="wide")

# Custom premium styling (Glassmorphism & Sleek Dark Mode)
st.markdown("""
<style>
    @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&display=swap');
    
    html, body, [class*="css"] {
        font-family: 'Outfit', sans-serif;
    }
    
    /* Main Background adjustments */
    .stApp {
        background-color: #0d0e12;
        color: #e2e8f0;
    }
    
    /* Premium Glassmorphic Cards */
    .glass-card {
        background: rgba(30, 41, 59, 0.45);
        backdrop-filter: blur(12px);
        -webkit-backdrop-filter: blur(12px);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 16px;
        padding: 24px;
        margin-bottom: 20px;
        box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
        transition: transform 0.2s ease, border-color 0.2s ease;
    }
    .glass-card:hover {
        transform: translateY(-2px);
        border-color: rgba(99, 102, 241, 0.4);
    }
    
    /* Custom Headers */
    .main-title {
        font-weight: 800;
        font-size: 2.8rem;
        background: linear-gradient(135deg, #a5b4fc 0%, #6366f1 50%, #4f46e5 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        margin-bottom: 5px;
    }
    .sub-title {
        color: #94a3b8;
        font-size: 1.1rem;
        margin-bottom: 30px;
        font-weight: 300;
        letter-spacing: 0.5px;
    }
    
    /* Prediction Cards */
    .pred-up {
        background: linear-gradient(135deg, rgba(16, 185, 129, 0.15) 0%, rgba(5, 150, 105, 0.05) 100%);
        border: 1px solid rgba(16, 185, 129, 0.3);
        border-radius: 12px;
        padding: 20px;
        color: #34d399;
        text-align: center;
    }
    .pred-down {
        background: linear-gradient(135deg, rgba(239, 68, 68, 0.15) 0%, rgba(220, 38, 38, 0.05) 100%);
        border: 1px solid rgba(239, 68, 68, 0.3);
        border-radius: 12px;
        padding: 20px;
        color: #f87171;
        text-align: center;
    }
    
    /* KPI Metric styling */
    .kpi-container {
        display: flex;
        justify-content: space-between;
        gap: 15px;
    }
    .kpi-box {
        flex: 1;
        background: rgba(30, 41, 59, 0.3);
        border: 1px solid rgba(255, 255, 255, 0.05);
        border-radius: 12px;
        padding: 20px;
        text-align: center;
    }
    .kpi-value {
        font-size: 2rem;
        font-weight: 700;
        color: #ffffff;
    }
    .kpi-label {
        font-size: 0.85rem;
        color: #94a3b8;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-top: 5px;
    }
    
    /* Database status badges */
    .badge {
        padding: 4px 10px;
        border-radius: 20px;
        font-size: 0.85rem;
        font-weight: 600;
        display: inline-block;
    }
    .badge-pending {
        background-color: rgba(245, 158, 11, 0.2);
        color: #f59e0b;
        border: 1px solid rgba(245, 158, 11, 0.4);
    }
    .badge-correct {
        background-color: rgba(16, 185, 129, 0.2);
        color: #10b981;
        border: 1px solid rgba(16, 185, 129, 0.4);
    }
    .badge-incorrect {
        background-color: rgba(239, 68, 68, 0.2);
        color: #ef4444;
        border: 1px solid rgba(239, 68, 68, 0.4);
    }
</style>
""", unsafe_allow_html=True)

# Custom header
st.markdown('<div class="main-title">📈 Google Stock Predictor</div>', unsafe_allow_html=True)
st.markdown('<div class="sub-title">Real-Time MLOps Inference & Prediction Logging System</div>', unsafe_allow_html=True)

# ================================
# DATABASE OPERATIONS (SQLite)
# ================================
DB_FILE = "predictions.db"

def init_db():
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute('''
        CREATE TABLE IF NOT EXISTS prediction_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            anchor_date TEXT NOT NULL,
            prediction_date TEXT NOT NULL,
            anchor_close REAL NOT NULL,
            predicted_class INTEGER NOT NULL,
            confidence REAL,
            actual_close REAL,
            actual_class INTEGER,
            status TEXT DEFAULT 'Pending'
        )
    ''')
    conn.commit()
    conn.close()

def log_prediction(anchor_date, prediction_date, anchor_close, predicted_class, confidence):
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    
    # Check if a prediction for this specific prediction_date already exists
    c.execute("SELECT id FROM prediction_logs WHERE prediction_date = ?", (prediction_date,))
    row = c.fetchone()
    if row:
        # Update it to the latest prediction if it's still pending
        c.execute('''
            UPDATE prediction_logs 
            SET anchor_date = ?, anchor_close = ?, predicted_class = ?, confidence = ?, status = 'Pending'
            WHERE id = ? AND status = 'Pending'
        ''', (anchor_date, anchor_close, predicted_class, confidence, row[0]))
    else:
        c.execute('''
            INSERT INTO prediction_logs (anchor_date, prediction_date, anchor_close, predicted_class, confidence)
            VALUES (?, ?, ?, ?, ?)
        ''', (anchor_date, prediction_date, anchor_close, predicted_class, confidence))
    conn.commit()
    conn.close()

def get_predictions_history():
    conn = sqlite3.connect(DB_FILE)
    df = pd.read_sql_query("SELECT * FROM prediction_logs ORDER BY timestamp DESC", conn)
    conn.close()
    return df

def resolve_pending_predictions():
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    
    # Fetch all Pending entries
    c.execute("SELECT id, prediction_date, anchor_close, predicted_class FROM prediction_logs WHERE status = 'Pending'")
    pending = c.fetchall()
    
    if not pending:
        conn.close()
        return
        
    today_str = datetime.now().strftime('%Y-%m-%d')
    ticker = yf.Ticker("GOOGL")
    updated_count = 0
    
    for db_id, pred_date_str, anchor_close, predicted_class in pending:
        # Only check predictions where target date has closed (is strictly in the past compared to today)
        if pred_date_str < today_str:
            # Query Yahoo Finance starting from pred_date_str (with 5-day buffer to skip weekends)
            start_date = datetime.strptime(pred_date_str, '%Y-%m-%d')
            end_date = start_date + timedelta(days=5)
            
            hist = ticker.history(start=start_date.strftime('%Y-%m-%d'), end=end_date.strftime('%Y-%m-%d'))
            
            if not hist.empty:
                # Retrieve first trading day closing price on or after the prediction_date
                actual_close = hist['Close'].iloc[0]
                actual_class = 1 if actual_close > anchor_close else 0
                status = 'Correct' if actual_class == predicted_class else 'Incorrect'
                
                c.execute('''
                    UPDATE prediction_logs
                    SET actual_close = ?, actual_class = ?, status = ?
                    WHERE id = ?
                ''', (float(actual_close), int(actual_class), status, db_id))
                updated_count += 1
                
    if updated_count > 0:
        conn.commit()
    conn.close()

# Initialize DB on startup
init_db()

# ================================
# MODEL & METRICS LOADING (Cached)
# ================================
@st.cache_resource
def load_model_data():
    try:
        # Load pre-trained model and evaluation artifacts
        return joblib.load("best_cls_model.joblib")
    except FileNotFoundError:
        # If model.joblib doesn't exist, automatically train the pipeline (self-healing)
        from train import train_and_save_pipeline
        return train_and_save_pipeline()

model_data = load_model_data()
best_cls_model = model_data['model']
loaded_scaler = model_data['scaler']
loaded_features = model_data['features']
cls_results = model_data['cls_results']
best_cls_name = model_data['best_cls_name']
reg_results = model_data['reg_results']
best_reg_name = model_data['best_reg_name']
best_reg_model = model_data['best_reg_model']
ks = model_data['ks']
inertias = model_data['inertias']
X_train = model_data['X_train']
X_val = model_data['X_val']
y_val_cls = model_data['y_val_cls']
X_test = model_data['X_test']
y_test_reg = model_data['y_test_reg']
historical_df = model_data['historical_df']

# ================================
# STREAMLIT GUI TABS
# ================================
tab1, tab2, tab3, tab4 = st.tabs([
    "🔴 Real-Time Predictor", 
    "📈 Real-World MLOps Dashboard",
    "📊 Model Comparisons & Diagnostics", 
    "📉 Historical Trends"
])

# -----------------
# TAB 1: Real-Time Predictor
# -----------------
with tab1:
    st.markdown('<div class="glass-card"><h3>Live Stock Prediction Panel</h3>'
                '<p>Fetch real-time metrics for Google Stock (GOOGL) via Yahoo Finance, scale indicators, and run model inference instantly.</p></div>', unsafe_allow_html=True)
    
    # Live data window (1 year to ensure enough historical data for SMA/EMA indicators)
    end_date = datetime.now()
    start_date = end_date - timedelta(days=365)
    
    with st.spinner("Downloading live stock data from Yahoo Finance..."):
        ticker = yf.Ticker("GOOGL")
        live_df = ticker.history(start=start_date.strftime('%Y-%m-%d'), end=end_date.strftime('%Y-%m-%d'))
        
    if not live_df.empty:
        # Display Current Price Card
        current_price = live_df['Close'].iloc[-1]
        latest_date_str = live_df.index[-1].strftime('%Y-%m-%d')
        
        col1, col2 = st.columns([1, 3])
        with col1:
            st.metric(label="Latest Google Close Price", value=f"${current_price:.2f}", delta=f"{current_price - live_df['Close'].iloc[-2]:.2f}")
            st.caption(f"Last updated session: {latest_date_str}")
        
        with col2:
            # Short-term Interactive Chart
            fig_rt = go.Figure()
            fig_rt.add_trace(go.Scatter(x=live_df.index[-90:], y=live_df['Close'].iloc[-90:], mode='lines+markers', name='Close Price', line=dict(color='#6366f1', width=2)))
            fig_rt.update_layout(
                title="Google Stock Close Price (Last 90 Days)", 
                margin=dict(l=20, r=20, t=40, b=20),
                paper_bgcolor='rgba(0,0,0,0)',
                plot_bgcolor='rgba(0,0,0,0)',
                font=dict(color='#94a3b8'),
                xaxis=dict(showgrid=False),
                yaxis=dict(gridcolor='rgba(255,255,255,0.05)')
            )
            st.plotly_chart(fig_rt, use_container_width=True)

        st.divider()

        # Calculate prediction date based on calendar weekdays (handles weekends)
        anchor_datetime = live_df.index[-1]
        pred_datetime = anchor_datetime + timedelta(days=1)
        if pred_datetime.weekday() == 5:    # Saturday -> Monday
            pred_datetime += timedelta(days=2)
        elif pred_datetime.weekday() == 6:  # Sunday -> Monday
            pred_datetime += timedelta(days=1)
        prediction_date_str = pred_datetime.strftime('%Y-%m-%d')
        
        st.subheader("Run Inference Pipeline")
        col_btn, col_info = st.columns([1, 2])
        
        with col_btn:
            predict_btn = st.button("🔮 Predict Next Day Movement", type="primary")
            
        with col_info:
            st.info(f"Target validation date for tomorrow: **{prediction_date_str}** (compared against today's close: **${current_price:.2f}**)")

        if predict_btn:
            temp_df = live_df.copy()
            # Construct feature engineering rolling indicators
            temp_df['SMA_20'] = temp_df['Close'].rolling(window=20).mean()
            temp_df['EMA_20'] = temp_df['Close'].ewm(span=20, adjust=False).mean()
            temp_df.dropna(inplace=True)
            
            if not temp_df.empty:
                # Fetch latest technical indicator feature row
                latest_data = temp_df[loaded_features].iloc[-1:].values
                scaled_data = loaded_scaler.transform(latest_data)
                
                # Inference
                pred = best_cls_model.predict(scaled_data)[0]
                
                # Calculate confidence score
                conf_str = "N/A"
                conf_val = 0.0
                if hasattr(best_cls_model, "predict_proba"):
                    probs = best_cls_model.predict_proba(scaled_data)[0]
                    conf_val = max(probs) * 100
                    conf_str = f"{conf_val:.2f}%"
                
                direction = "UP" if pred == 1 else "DOWN"
                
                # Log predictions to SQLite Database
                log_prediction(
                    anchor_date=latest_date_str,
                    prediction_date=prediction_date_str,
                    anchor_close=float(current_price),
                    predicted_class=int(pred),
                    confidence=float(conf_val) if conf_val > 0 else None
                )
                
                # Render results HTML with beautiful styling
                if direction == "UP":
                    st.markdown(f"""
                        <div class="pred-up">
                            <h2>Prediction: 📈 GOOGL is going UP tomorrow!</h2>
                            <p>Confidence Level: <strong>{conf_str}</strong></p>
                        </div>
                    """, unsafe_allow_html=True)
                else:
                    st.markdown(f"""
                        <div class="pred-down">
                            <h2>Prediction: 📉 GOOGL is going DOWN tomorrow!</h2>
                            <p>Confidence Level: <strong>{conf_str}</strong></p>
                        </div>
                    """, unsafe_allow_html=True)
                
                st.success(f"💾 Prediction successfully logged to SQLite local store. Status set to **Pending** until target trading close of {prediction_date_str}.")
            else:
                st.error("Not enough recent data fetched to compute moving averages.")
    else:
        st.error("Failed to fetch live data from Yahoo Finance.")

# -----------------
# TAB 2: Real-World MLOps Dashboard
# -----------------
with tab2:
    st.markdown('<div class="glass-card"><h3>Live Production Performance Tracker</h3>'
                '<p>This panel shows the production track record of your model. It queries the local SQLite log, automatically pulls historical outcomes when target dates finish, and computes actual real-world accuracy.</p></div>', unsafe_allow_html=True)
    
    # Process pending outcomes
    with st.spinner("Resolving pending predictions..."):
        resolve_pending_predictions()
        
    df_history = get_predictions_history()
    
    if df_history.empty:
        st.info("No predictions logged yet. Run predictions in the 'Real-Time Predictor' tab to start logging records.")
    else:
        # Separate pending and evaluated
        evaluated_df = df_history[df_history['status'] != 'Pending']
        pending_df = df_history[df_history['status'] == 'Pending']
        
        # Calculate Real-World Stats
        total_predictions = len(df_history)
        pending_predictions = len(pending_df)
        evaluated_count = len(evaluated_df)
        
        hit_rate = "N/A"
        correct_count = 0
        if evaluated_count > 0:
            correct_count = len(evaluated_df[evaluated_df['status'] == 'Correct'])
            hit_rate = f"{(correct_count / evaluated_count) * 100:.1f}%"
            
        # Draw dynamic CSS KPI containers
        st.markdown(f"""
            <div class="kpi-container">
                <div class="kpi-box">
                    <div class="kpi-value">{total_predictions}</div>
                    <div class="kpi-label">Total Logs</div>
                </div>
                <div class="kpi-box">
                    <div class="kpi-value">{pending_predictions}</div>
                    <div class="kpi-label">Pending Target Dates</div>
                </div>
                <div class="kpi-box">
                    <div class="kpi-value" style="color: #6366f1;">{evaluated_count}</div>
                    <div class="kpi-label">Evaluated Logs</div>
                </div>
                <div class="kpi-box">
                    <div class="kpi-value" style="color: #10b981;">{hit_rate}</div>
                    <div class="kpi-label">Real-World Hit Rate</div>
                </div>
            </div>
        """, unsafe_allow_html=True)
        
        st.write(" ")
        
        col_charts_left, col_charts_right = st.columns(2)
        
        with col_charts_left:
            # Cumulative Accuracy over time
            if evaluated_count > 0:
                # Sort chronological
                eval_chron = evaluated_df.iloc[::-1].copy()
                eval_chron['is_correct'] = (eval_chron['status'] == 'Correct').astype(int)
                eval_chron['cumulative_correct'] = eval_chron['is_correct'].cumsum()
                eval_chron['trial_num'] = np.arange(1, len(eval_chron) + 1)
                eval_chron['rolling_accuracy'] = (eval_chron['cumulative_correct'] / eval_chron['trial_num']) * 100
                
                fig_roll = go.Figure()
                fig_roll.add_trace(go.Scatter(x=eval_chron['timestamp'], y=eval_chron['rolling_accuracy'], mode='lines+markers', name='Live Performance', line=dict(color='#10b981', width=3)))
                fig_roll.update_layout(
                    title="Real-World Accuracy Curve Over Time (%)",
                    margin=dict(l=20, r=20, t=40, b=20),
                    paper_bgcolor='rgba(0,0,0,0)',
                    plot_bgcolor='rgba(0,0,0,0)',
                    font=dict(color='#94a3b8'),
                    yaxis=dict(range=[0, 100], gridcolor='rgba(255,255,255,0.05)'),
                    xaxis=dict(showgrid=False)
                )
                st.plotly_chart(fig_roll, use_container_width=True)
            else:
                st.info("Accuracy tracking chart will populate once predictions target dates pass and resolve.")
                
        with col_charts_right:
            # Breakdown of classes
            if total_predictions > 0:
                labels = ['Correct', 'Incorrect', 'Pending']
                values = [
                    len(df_history[df_history['status'] == 'Correct']),
                    len(df_history[df_history['status'] == 'Incorrect']),
                    len(df_history[df_history['status'] == 'Pending'])
                ]
                # Filter out zeroes
                colors = ['#10b981', '#ef4444', '#f59e0b']
                filtered_labels = [l for l, v in zip(labels, values) if v > 0]
                filtered_colors = [c for c, v in zip(colors, values) if v > 0]
                filtered_values = [v for v in values if v > 0]
                
                fig_pie = go.Figure(data=[go.Pie(labels=filtered_labels, values=filtered_values, hole=.4, marker=dict(colors=filtered_colors))])
                fig_pie.update_layout(
                    title="Outcome Status Breakdown",
                    margin=dict(l=20, r=20, t=40, b=20),
                    paper_bgcolor='rgba(0,0,0,0)',
                    plot_bgcolor='rgba(0,0,0,0)',
                    font=dict(color='#94a3b8')
                )
                st.plotly_chart(fig_pie, use_container_width=True)

        st.subheader("SQLite Prediction Log History")
        
        # Display a readable formatted dataframe
        display_df = df_history.copy()
        
        # Re-map columns for premium visual presentation
        display_df['predicted_class'] = display_df['predicted_class'].apply(lambda x: "📈 UP" if x == 1 else "📉 DOWN")
        display_df['confidence'] = display_df['confidence'].apply(lambda x: f"{x:.2f}%" if pd.notnull(x) else "N/A")
        display_df['anchor_close'] = display_df['anchor_close'].apply(lambda x: f"${x:.2f}")
        display_df['actual_close'] = display_df['actual_close'].apply(lambda x: f"${x:.2f}" if pd.notnull(x) else "N/A")
        
        # Format actual class
        def format_actual(x):
            if pd.isnull(x): return "Pending"
            return "📈 UP" if x == 1 else "📉 DOWN"
        display_df['actual_class'] = display_df['actual_class'].apply(format_actual)
        
        # Rename columns to user friendly text
        display_df.columns = [
            'Log ID', 'Timestamp Logged', 'Anchor Date', 'Target Predict Date', 
            'Anchor Price', 'Predicted Movement', 'Confidence', 'Actual Price', 
            'Actual Movement', 'Status'
        ]
        
        st.dataframe(display_df, use_container_width=True)

# -----------------
# TAB 3: Model Diagnostics
# -----------------
with tab3:
    st.header("Offline Trained Metrics & Comparisons")
    st.write("These metrics represent performance measured on historical validation datasets during offline model training.")
    
    col1, col2 = st.columns(2)
    with col1:
        st.subheader("Classification Models (Accuracy Ranking)")
        st.dataframe(cls_results.style.format(precision=3))
        st.write(f"🎉 **Selected Best Production Classifier:** {best_cls_name}")
        
    with col2:
        st.subheader("Regression Models (R2 Ranking)")
        st.dataframe(reg_results.style.format(precision=3))
        st.write(f"🎉 **Selected Best Production Regressor:** {best_reg_name}")

    st.divider()
    
    col_retrain, col_retrain_info = st.columns([1, 2])
    with col_retrain:
        trigger_retrain = st.button("🔄 Retrain ML Models Offline", type="secondary")
    with col_retrain_info:
        st.caption("Re-run train.py algorithm pipeline, scan the updated CSV, re-optimize model search, and save changes to joblib.")
        
    if trigger_retrain:
        with st.spinner("Retraining all models on updated dataset..."):
            from train import train_and_save_pipeline
            # Run pipeline
            new_data = train_and_save_pipeline()
            # Clear resource cache to reload new values
            st.cache_resource.clear()
            st.success("Successfully retrained models! Refreshing...")
            st.rerun()

    st.divider()
    
    # Classification Validation Visualizations
    st.subheader(f"Best Classification Model Diagnostics ({best_cls_name})")
    col3, col4 = st.columns(2)
    
    with col3:
        st.write("**Confusion Matrix (Validation Set)**")
        preds_cls = best_cls_model.predict(X_val)
        cm = confusion_matrix(y_val_cls, preds_cls)
        
        fig_cm, ax_cm = plt.subplots(figsize=(4, 4))
        ax_cm.matshow(cm, cmap='Blues', alpha=0.7)
        for i in range(cm.shape[0]):
            for j in range(cm.shape[1]):
                ax_cm.text(x=j, y=i, s=cm[i, j], va='center', ha='center', fontweight='bold', fontsize=12)
        ax_cm.set_xticklabels(['', 'Down', 'Up'])
        ax_cm.set_yticklabels(['', 'Down', 'Up'])
        plt.xlabel('Predicted Label')
        plt.ylabel('True Label')
        fig_cm.patch.set_alpha(0.0) # Transparent background
        st.pyplot(fig_cm)
        
    with col4:
        st.write("**ROC Curve (Validation Set)**")
        if hasattr(best_cls_model, "predict_proba"):
            probs_cls = best_cls_model.predict_proba(X_val)[:, 1]
            fpr, tpr, _ = roc_curve(y_val_cls, probs_cls)
            fig_roc = go.Figure()
            fig_roc.add_trace(go.Scatter(x=fpr, y=tpr, mode='lines', name='ROC Curve (AUC)', line=dict(color='#6366f1', width=3)))
            fig_roc.add_trace(go.Scatter(x=[0,1], y=[0,1], mode='lines', line=dict(dash='dash', color='rgba(255,255,255,0.2)'), name='Random Chance'))
            fig_roc.update_layout(
                xaxis_title="False Positive Rate", 
                yaxis_title="True Positive Rate",
                margin=dict(l=20, r=20, t=40, b=20),
                paper_bgcolor='rgba(0,0,0,0)',
                plot_bgcolor='rgba(0,0,0,0)',
                font=dict(color='#94a3b8'),
                xaxis=dict(showgrid=False),
                yaxis=dict(gridcolor='rgba(255,255,255,0.05)')
            )
            st.plotly_chart(fig_roc, use_container_width=True)
        else:
            st.warning("ROC Curve unavailable for this model type.")
            
    st.divider()
    
    # Regression & Clustering Vis
    col5, col6 = st.columns(2)
    with col5:
        st.subheader(f"Best Regression Model Performance ({best_reg_name})")
        preds_reg = best_reg_model.predict(X_test)
        
        fig_reg = go.Figure()
        fig_reg.add_trace(go.Scatter(y=y_test_reg[-100:], mode='lines', name='Actual Price', line=dict(color='#94a3b8', width=1.5)))
        fig_reg.add_trace(go.Scatter(y=preds_reg[-100:], mode='lines', name='Predicted Price', line=dict(color='#ef4444', width=2)))
        fig_reg.update_layout(
            title="Actual vs Predicted (Last 100 Test Samples)",
            margin=dict(l=20, r=20, t=40, b=20),
            paper_bgcolor='rgba(0,0,0,0)',
            plot_bgcolor='rgba(0,0,0,0)',
            font=dict(color='#94a3b8'),
            xaxis=dict(showgrid=False),
            yaxis=dict(gridcolor='rgba(255,255,255,0.05)')
        )
        st.plotly_chart(fig_reg, use_container_width=True)
        
    with col6:
        st.subheader("Clustering Check: KMeans Elbow Method")
        fig_elb = go.Figure()
        fig_elb.add_trace(go.Scatter(x=ks, y=inertias, mode='lines+markers', line=dict(color='#a5b4fc', width=2), marker=dict(size=8)))
        fig_elb.update_layout(
            xaxis_title="Number of Clusters (k)", 
            yaxis_title="Inertia",
            margin=dict(l=20, r=20, t=40, b=20),
            paper_bgcolor='rgba(0,0,0,0)',
            plot_bgcolor='rgba(0,0,0,0)',
            font=dict(color='#94a3b8'),
            xaxis=dict(showgrid=False, dtick=1),
            yaxis=dict(gridcolor='rgba(255,255,255,0.05)')
        )
        st.plotly_chart(fig_elb, use_container_width=True)

    st.divider()
    
    st.subheader(f"🧠 Explainability: SHAP Feature Importance ({best_cls_name})")
    st.write("SHAP values analyze feature impact on individual validation predictions. Explains *why* the model acts as it does.")
    
    with st.spinner("Calculating SHAP feature importances..."):
        try:
            # Sample subset for rapid explanation computation
            X_val_sample = X_val[:100] if len(X_val) > 100 else X_val
            
            if hasattr(best_cls_model, 'feature_importances_'):
                explainer = shap.TreeExplainer(best_cls_model)
                shap_values = explainer.shap_values(X_val_sample)
            else:
                background = shap.kmeans(X_train, 10)
                pred_func = best_cls_model.predict_proba if hasattr(best_cls_model, "predict_proba") else best_cls_model.predict
                explainer = shap.KernelExplainer(pred_func, background)
                shap_values = explainer.shap_values(X_val_sample)

            # Extract dimensions for binary classifier plotting
            if isinstance(shap_values, list) and len(shap_values) > 1:
                shap_values_to_plot = shap_values[1]
            elif isinstance(shap_values, np.ndarray) and len(shap_values.shape) == 3:
                shap_values_to_plot = shap_values[:, :, 1]
            else:
                shap_values_to_plot = shap_values
                
            fig_shap, ax_shap = plt.subplots(figsize=(8, 4))
            shap.summary_plot(shap_values_to_plot, X_val_sample, feature_names=loaded_features, show=False)
            fig_shap.patch.set_alpha(0.0) # Transparent background
            # Apply styling to labels
            for text in ax_shap.texts + ax_shap.get_xticklabels() + ax_shap.get_yticklabels():
                text.set_color('#94a3b8')
            st.pyplot(fig_shap)
        except Exception as e:
            st.warning(f"SHAP diagnostics could not be run for {best_cls_name}. Reason: {e}")

# -----------------
# TAB 4: Historical Trends
# -----------------
with tab4:
    st.header("Historical Close Price & Dataset Reference")
    st.write("This represents the raw historical CSV dataset (`googl_daily_prices.csv`) with rolling technical indicators.")
    
    st.subheader("Price Trend with Moving Averages")
    fig_hist = go.Figure()
    fig_hist.add_trace(go.Scatter(x=historical_df['Date'], y=historical_df['Close'], name='Close Price', line=dict(color='#94a3b8')))
    fig_hist.add_trace(go.Scatter(x=historical_df['Date'], y=historical_df['SMA_20'], name='SMA 20', line=dict(color='#34d399', dash='dot')))
    fig_hist.add_trace(go.Scatter(x=historical_df['Date'], y=historical_df['EMA_20'], name='EMA 20', line=dict(color='#f43f5e', dash='dash')))
    fig_hist.update_layout(
        xaxis_title="Date", 
        yaxis_title="Price (USD)",
        margin=dict(l=20, r=20, t=40, b=20),
        paper_bgcolor='rgba(0,0,0,0)',
        plot_bgcolor='rgba(0,0,0,0)',
        font=dict(color='#94a3b8'),
        xaxis=dict(showgrid=False),
        yaxis=dict(gridcolor='rgba(255,255,255,0.05)')
    )
    st.plotly_chart(fig_hist, use_container_width=True)
    
    st.subheader("Dataset Preview (Latest 50 Entries)")
    st.dataframe(historical_df.tail(50), use_container_width=True)
