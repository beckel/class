% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function connection = cer_db_get_connection()
	db_name = 'CER_Electricity';
	driver = 'com.mysql.jdbc.Driver';
	address = 'webofenergy.inf.ethz.ch';
	port = '3306';
	URL = ['jdbc:mysql://', address, ':', port, '/', db_name];
	user = 'cer_user';
	password = 'secret';

	connection = database(db_name, user, password, driver, URL);
end
