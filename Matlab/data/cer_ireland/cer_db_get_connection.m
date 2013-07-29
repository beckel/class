function connection = cer_db_get_connection()
	db_name = 'CER_Electricity';
	driver = 'com.mysql.jdbc.Driver';
	address = '127.0.0.1';
	port = '3306';
	URL = ['jdbc:mysql://', address, ':', port, '/', db_name];
	user = 'read_only';
	password = '';

	connection = database(db_name, user, password, driver, URL);
end