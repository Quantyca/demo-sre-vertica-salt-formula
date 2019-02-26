# Create DB
/opt/vertica/bin/adminTools -t create_db -d vertica_dev -s 10.144.130.106 -p "vertica2018"

# Check DB
echo "Di seguito i database UP:"
/opt/vertica/bin/adminTools -t db_status -s UP
