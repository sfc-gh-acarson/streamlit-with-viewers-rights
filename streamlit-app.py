import streamlit as st
from snowflake.snowpark.context import get_active_session

session = get_active_session()

current_role = session.get_current_role().strip('"')

@st.dialog(f"👤 New sales entry with role {current_role}",width='large') 
def render_popup():
    
    st.markdown("""            
            <hr style="border: 1px solid #008455; margin-top: -2px;">
            """, unsafe_allow_html=True
        )    

    header_cols = st.columns(2)
    
    sales_rep = header_cols[0].selectbox(
        "Sales Rep",
        options=["Alice", "Henry", "Grace", "Frank"],
        placeholder="Select Sales Rep...",
        index=None
    )
    region = header_cols[1].selectbox(
        "Region",
        options=["North", "South", "East", "West"],
        placeholder="Select Region...",
        index=None
    )
    
    st.markdown("""            
            <hr style="border: none; border-top: 1px solid #e2e3e4; margin-top: 8px;">
            """, unsafe_allow_html=True
        )

    amount = st.number_input(
        "Sales Amount",value=None,  min_value=1000, max_value=1000000, step=1000,
        format="%d",icon="💲", # 💸 💵 attach_money thumb_up
        placeholder='Enter sales amount ... '
        , key='2'
    )
  
        
    notes = st.text_area("Notes",placeholder="Enter notes ...", disabled=False, key="notes")
    
    st.divider()

    footer_cols = st.columns(4)    
    close = footer_cols[0].button(":red[Close]", use_container_width=True)    
    save = footer_cols[3].button(":green[Submit]", use_container_width=True)
    if save:
        sql = f"""
            INSERT INTO SALES_DATA (REGION, SALES_REP, SALES_AMOUNT)
            VALUES 
              ('{region}', '{sales_rep}', {amount});
        """

        try:
            with st.spinner("Processing request..."):
                session.sql(sql).collect()
            st.success("Successfully submitted new record!")
        except Exception as e:
            st.error(f"Submission failed: {e}")
    if close:
        st.rerun()


st.markdown("""
            ### ⚡ Restricted Caller's Rights 
""")
st.caption("See how Snowflake apps can run with least-privilege access using Restricted Caller Rights.")

sql = f"""
    SELECT 
        ID,
        REGION,
        SALES_REP,        
        TO_VARCHAR(SALES_AMOUNT, '$99,999') AS SALES_AMOUNT,
        CREATED_AT
    FROM SALES_DATA 
    ORDER BY 1;
"""

grid_header_cols = st.columns([3, 1, 1], vertical_alignment="center")

grid_header_cols[0].markdown(f"""
                             ###### 👤 {current_role}
""")

grid_header_cols[1].button(
    ":material/add_circle_outline: Add New",
    use_container_width=True,
    on_click=render_popup   
)

grid_header_cols[2].button(
    ":material/refresh: Refresh", use_container_width=True
)

df = session.sql(sql).collect()

column_config = {
    "ID": st.column_config.TextColumn("🆔 Sales Rep ID", disabled=True),
    "REGION": st.column_config.TextColumn("📍 Region", required=True, disabled=False),    
    "SALES_REP": st.column_config.TextColumn("🧑‍💼 Sales Rep", required=True, disabled=True),
    "SALES_AMOUNT": st.column_config.TextColumn("💸 Sales Amount", required=True, disabled=True),
    "CREATED_AT": st.column_config.DateColumn("📅 Created Date", required=True, disabled=True)
}


st.data_editor(
    df,
    height=350, 
    hide_index=True,
    column_config=column_config
)

st.markdown(
    f"""Displaying {len(df)} of {len(df)} rows based on filters.

---
"""
)
