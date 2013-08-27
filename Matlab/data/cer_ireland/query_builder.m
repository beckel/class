% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function query = query_builder(select, from, where, orderby, groupby, having)
	if (nargin < 2)
		error('A query needs at least a SELECT and FROM clause!');
	end
	if (nargin < 6)
		having = [];
	end
	if (nargin < 5)
		groupby = [];
	end
	if (nargin < 4)
		orderby = [];
	end
	if (nargin < 3)
		where = [];
	end

	query = 'SELECT ';
	if (ischar(select))
		query = [query, select];
	else
		query = [query, select{1}];
		for i = 2:length(select)
			query = [query, ', ', select{i}];
		end
	end
	query = [query, ' FROM ', from];
	
	if (not(isempty(where)))
		query = [query, ' WHERE '];
		if (ischar(where))
			query = [query, '(', where, ')'];
		else
			query = [query, '(', where{1}, ')'];
			for i = 2:length(where)
				query = [query, ' AND ', '(', where{i}, ')'];
			end
		end
	end
	if (not(isempty(groupby)))
		query = [query, ' GROUP BY '];
		if (ischar(groupby))
			query = [query, groupby];
		else
			query = [query, groupby{1}];
			for i = 2:length(groupby)
				query = [query, ', ', groupby{i}];
			end
		end
	end
	if (not(isempty(having)))
		query = [query, ' HAVING '];
		if (ischar(having))
			query = [query, having];
		else
			query = [query, having{1}];
			for i = 2:length(having)
				query = [query, ' AND ', having{i}];
			end
		end
	end
	if (not(isempty(orderby)))
		query = [query, ' ORDER BY '];
		if (ischar(orderby))
			query = [query, orderby];
		else
			query = [query, orderby{1}];
			for i = 2:length(orderby)
				query = [query, ', ', orderby{i}];
			end
		end
	end
end