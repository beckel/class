%% Add to Matlab search path

addpath('data/');
addpath('data/cer_ireland');
addpath('data/cer_ireland/weekly_traces');
addpath('data/aarau');

addpath('data_selection');

addpath('features');
addpath('features/48');
addpath('features/48/consumption');
addpath('features/48/ratios');
addpath('features/48/statistical');
addpath('features/48/temporal');
addpath('features/96');
addpath('features/96/distribution');

addpath('featuresets');

addpath('projects');
addpath('projects/confidence');

addpath('util');

addpath('lib');
addpath('lib/YAMLMatlab_0.4.3');
addpath('lib/libsvm/');
addpath('lib/libsvm/matlab/');

addpath('plot');
addpath('plot/images');

addpath('properties');
addpath('properties/apriori_classes');
addpath('properties/classes');

warning off
rmpath([matlabroot '/toolbox/bioinfo/biolearning']);
warning on

javaaddpath('lib/mysql-connector-java-5.1.24-bin.jar');
