% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

clc;
close all;
clearvars;

dest_dir = 'tmp/csvfiles/';
if ~exist(dest_dir, 'dir')
    mkdir(dest_dir);
end

files = dir('data/cer_ireland/weekly_traces/*.mat');
for file = files'
    load(file.name);
    filename = file.name(1:4);
    csvwrite([dest_dir, filename, '.csv'], Consumer.consumption);
%    dlmwrite([dest_dir, filename, '.csv'], Consumer.timeline(:,1), 'delimiter', ',', 'precision', 6); 
end
