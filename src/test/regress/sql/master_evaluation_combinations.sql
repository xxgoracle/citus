
-- This test relies on metadata being synced
-- that's why is should be executed on MX schedule
CREATE SCHEMA master_evaluation_combinations;
SET search_path TO master_evaluation_combinations;

-- create a volatile function that returns the local node id
CREATE OR REPLACE FUNCTION get_local_node_id_volatile()
RETURNS INT AS $$
DECLARE localGroupId int;
BEGIN
	SELECT groupid INTO localGroupId FROM pg_dist_local_group;
  RETURN localGroupId;
END; $$ language plpgsql VOLATILE;
SELECT create_distributed_function('get_local_node_id_volatile()');

CREATE TYPE user_data AS (name text, age int);

CREATE TABLE user_info_data (user_id int, u_data user_data);
SELECT create_distributed_table('user_info_data', 'user_id');

-- show that local id is 0, we'll use this information
SELECT get_local_node_id_volatile();

-- load data
INSERT INTO user_info_data SELECT i, ('name' || i, i % 20 + 20)::user_data FROM generate_series(0,100)i;

-- we expect that the function is evaluated on the worker node, so we should get a row
SELECT get_local_node_id_volatile() > 0 FROM user_info_data WHERE user_id = 1;


-- make sure that it is also true for  fast-path router queries with paramaters
PREPARE fast_path_router_with_param(int) AS SELECT count(*) FROM user_info_data WHERE user_id  = $1;

execute fast_path_router_with_param(1);
execute fast_path_router_with_param(2);
execute fast_path_router_with_param(3);
execute fast_path_router_with_param(4);
execute fast_path_router_with_param(5);
execute fast_path_router_with_param(6);
execute fast_path_router_with_param(7);
execute fast_path_router_with_param(8);


-- make sure that it is also true for  fast-path router queries with paramaters
PREPARE fast_path_router_with_param_and_func(int) AS SELECT get_local_node_id_volatile() > 0 FROM user_info_data WHERE user_id  = $1;

execute fast_path_router_with_param_and_func(1);
execute fast_path_router_with_param_and_func(2);
execute fast_path_router_with_param_and_func(3);
execute fast_path_router_with_param_and_func(4);
execute fast_path_router_with_param_and_func(5);
execute fast_path_router_with_param_and_func(6);
execute fast_path_router_with_param_and_func(7);
execute fast_path_router_with_param_and_func(8);


PREPARE fast_path_router_with_param_on_non_dist_key_and_func(user_data) AS SELECT get_local_node_id_volatile() > 0 FROM user_info_data WHERE user_id = 1 AND u_data  = $1;
EXECUTE fast_path_router_with_param_on_non_dist_key_and_func(('test', 1)::user_data);
EXECUTE fast_path_router_with_param_on_non_dist_key_and_func(('test', 1)::user_data);
EXECUTE fast_path_router_with_param_on_non_dist_key_and_func(('test', 1)::user_data);
EXECUTE fast_path_router_with_param_on_non_dist_key_and_func(('test', 1)::user_data);
EXECUTE fast_path_router_with_param_on_non_dist_key_and_func(('test', 1)::user_data);
EXECUTE fast_path_router_with_param_on_non_dist_key_and_func(('test', 1)::user_data);
EXECUTE fast_path_router_with_param_on_non_dist_key_and_func(('test', 1)::user_data);
EXECUTE fast_path_router_with_param_on_non_dist_key_and_func(('test', 1)::user_data);
EXECUTE fast_path_router_with_param_on_non_dist_key_and_func(('test', 1)::user_data);

PREPARE fast_path_router_with_param_on_non_dist_key(user_data) AS SELECT count(*) FROM user_info_data WHERE user_id = 1 AND u_data  = $1;
EXECUTE fast_path_router_with_param_on_non_dist_key(('test', 1)::user_data);
EXECUTE fast_path_router_with_param_on_non_dist_key(('test', 1)::user_data);
EXECUTE fast_path_router_with_param_on_non_dist_key(('test', 1)::user_data);
EXECUTE fast_path_router_with_param_on_non_dist_key(('test', 1)::user_data);
EXECUTE fast_path_router_with_param_on_non_dist_key(('test', 1)::user_data);
EXECUTE fast_path_router_with_param_on_non_dist_key(('test', 1)::user_data);
EXECUTE fast_path_router_with_param_on_non_dist_key(('test', 1)::user_data);
EXECUTE fast_path_router_with_param_on_non_dist_key(('test', 1)::user_data);



PREPARE fast_path_router_with_two_params(user_data, int) AS SELECT count(*) FROM user_info_data WHERE user_id = $2 AND u_data  = $1;

EXECUTE fast_path_router_with_two_params(('test', 1)::user_data, 1);
EXECUTE fast_path_router_with_two_params(('test', 1)::user_data, 1);
EXECUTE fast_path_router_with_two_params(('test', 1)::user_data, 1);
EXECUTE fast_path_router_with_two_params(('test', 1)::user_data, 1);
EXECUTE fast_path_router_with_two_params(('test', 1)::user_data, 1);
EXECUTE fast_path_router_with_two_params(('test', 1)::user_data, 1);
EXECUTE fast_path_router_with_two_params(('test', 1)::user_data, 1);
EXECUTE fast_path_router_with_two_params(('test', 1)::user_data, 1);
EXECUTE fast_path_router_with_two_params(('test', 1)::user_data, 1);


PREPARE fast_path_router_with_only_function AS SELECT get_local_node_id_volatile() > 0 FROM user_info_data WHERE user_id = 1;
EXECUTE fast_path_router_with_only_function;
EXECUTE fast_path_router_with_only_function;
EXECUTE fast_path_router_with_only_function;
EXECUTE fast_path_router_with_only_function;
EXECUTE fast_path_router_with_only_function;
EXECUTE fast_path_router_with_only_function;
EXECUTE fast_path_router_with_only_function;
EXECUTE fast_path_router_with_only_function;

-- make sure that it is also true for  fast-path router queries with paramaters
PREPARE router_with_param(int) AS SELECT count(*) FROM user_info_data u1 JOIN user_info_data u2 USING (user_id) WHERE user_id  = $1;

execute router_with_param(1);
execute router_with_param(2);
execute router_with_param(3);
execute router_with_param(4);
execute router_with_param(5);
execute router_with_param(6);
execute router_with_param(7);
execute router_with_param(8);


PREPARE router_with_param_and_func(int) AS SELECT get_local_node_id_volatile() > 0 FROM user_info_data m1 JOIN user_info_data m2 USING(user_id) WHERE m1.user_id  = $1;

execute router_with_param_and_func(1);
execute router_with_param_and_func(2);
execute router_with_param_and_func(3);
execute router_with_param_and_func(4);
execute router_with_param_and_func(5);
execute router_with_param_and_func(6);
execute router_with_param_and_func(7);
execute router_with_param_and_func(8);

-- same query as router_with_param, but with consts
SELECT get_local_node_id_volatile() > 0 FROM user_info_data m1 JOIN user_info_data m2 USING(user_id) WHERE m1.user_id  = 1;


PREPARE router_with_param_on_non_dist_key(user_data) AS SELECT count(*) FROM user_info_data u1 JOIN user_info_data u2 USING (user_id) WHERE u1.user_id = 1 AND u1.u_data  = $1;
EXECUTE router_with_param_on_non_dist_key(('test', 1)::user_data);
EXECUTE router_with_param_on_non_dist_key(('test', 1)::user_data);
EXECUTE router_with_param_on_non_dist_key(('test', 1)::user_data);
EXECUTE router_with_param_on_non_dist_key(('test', 1)::user_data);
EXECUTE router_with_param_on_non_dist_key(('test', 1)::user_data);
EXECUTE router_with_param_on_non_dist_key(('test', 1)::user_data);
EXECUTE router_with_param_on_non_dist_key(('test', 1)::user_data);
EXECUTE router_with_param_on_non_dist_key(('test', 1)::user_data);
EXECUTE router_with_param_on_non_dist_key(('test', 1)::user_data);

PREPARE router_with_param_on_non_dist_key_and_func(user_data) AS SELECT get_local_node_id_volatile() > 0 FROM user_info_data u1 JOIN user_info_data u2 USING (user_id) WHERE u1.user_id = 1 AND u1.u_data  = $1;
EXECUTE router_with_param_on_non_dist_key_and_func(('test', 1)::user_data);
EXECUTE router_with_param_on_non_dist_key_and_func(('test', 1)::user_data);
EXECUTE router_with_param_on_non_dist_key_and_func(('test', 1)::user_data);
EXECUTE router_with_param_on_non_dist_key_and_func(('test', 1)::user_data);
EXECUTE router_with_param_on_non_dist_key_and_func(('test', 1)::user_data);
EXECUTE router_with_param_on_non_dist_key_and_func(('test', 1)::user_data);
EXECUTE router_with_param_on_non_dist_key_and_func(('test', 1)::user_data);
EXECUTE router_with_param_on_non_dist_key_and_func(('test', 1)::user_data);
EXECUTE router_with_param_on_non_dist_key_and_func(('test', 1)::user_data);


PREPARE router_with_two_params(user_data, int) AS SELECT count(*) FROM user_info_data u1 JOIN user_info_data u2 USING (user_id) WHERE user_id = $2 AND u1.u_data  = $1;

EXECUTE router_with_two_params(('test', 1)::user_data, 1);
EXECUTE router_with_two_params(('test', 1)::user_data, 1);
EXECUTE router_with_two_params(('test', 1)::user_data, 1);
EXECUTE router_with_two_params(('test', 1)::user_data, 1);
EXECUTE router_with_two_params(('test', 1)::user_data, 1);
EXECUTE router_with_two_params(('test', 1)::user_data, 1);
EXECUTE router_with_two_params(('test', 1)::user_data, 1);
EXECUTE router_with_two_params(('test', 1)::user_data, 1);
EXECUTE router_with_two_params(('test', 1)::user_data, 1);


PREPARE router_with_only_function AS SELECT get_local_node_id_volatile() > 0 FROM user_info_data u1 JOIN user_info_data u2 USING(user_id) WHERE user_id = 1;
EXECUTE router_with_only_function;
EXECUTE router_with_only_function;
EXECUTE router_with_only_function;
EXECUTE router_with_only_function;
EXECUTE router_with_only_function;
EXECUTE router_with_only_function;
EXECUTE router_with_only_function;
EXECUTE router_with_only_function;



DROP SCHEMA master_evaluation_combinations CASCADE;

