function connection = cer_db_get_connection()
	db_name = 'CER_Electricity';
	driver = 'com.mysql.jdbc.Driver';
	address = 'webofenergy.inf.ethz.ch';
	port = '3306';
	URL = ['jdbc:mysql://', address, ':', port, '/', db_name];
	user = 'cer_user';
	password = 's43lgsd03k%L!';

	connection = database(db_name, user, password, driver, URL);
end