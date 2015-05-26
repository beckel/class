% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

%% Add to Matlab search path

addpath('algo/');
addpath('algo/featureselection/');

addpath('classifier/');

addpath('data/');
addpath('data/cer_ireland');
addpath('data/cer_ireland/weekly_traces');
addpath('data/cer_ireland/astro');
addpath('data/cer_ireland/temperature');
addpath('data/cer_ireland/heating');
addpath('data/cer_ireland/clusters');

addpath('data/issm');
% addpath('data/issm/questionnaires');
% addpath('data/issm/consumption');
% addpath('data/issm/weekly_traces');

addpath('data_selection');

addpath('eval');

addpath('features');
addpath('features/consumption');
addpath('features/ratios');
addpath('features/statistical');
addpath('features/distribution');
addpath('features/multi_week');
addpath('features/temporal');
addpath('features/util');
addpath('features/new');
addpath('features/load_curve');

addpath('featuresets');

addpath('projects');

addpath('util');

addpath('lib');
addpath('lib/export_fig');
addpath('lib/heatmaps/');
addpath('lib/libsvm-3.17/');
addpath('lib/libsvm-3.17/matlab/');
addpath('lib/linemarkers');
addpath('lib/matlab2tikz');
addpath('lib/matlab2tikz/src');
addpath('lib/matlab2tikz/tools');
addpath('lib/tree/');
addpath('lib/YAMLMatlab_0.4.3');

addpath('plot');
addpath('plot/images');

addpath('properties/');
addpath('properties/apriori_classes/');
addpath('properties/classes/');
addpath('properties/classes/appliance_stock/');
addpath('properties/classes/appliance_usage/');
addpath('properties/regression/');

addpath('results');

warning off
rmpath([matlabroot '/toolbox/bioinfo/biolearning']);
warning on

javaaddpath('lib/mysql-connector-java-5.1.24-bin.jar');
