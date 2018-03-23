%% Part I: julia_task_switching & baseline_pt_ctx_switch : BOXPLOT
clear all;
fid_baseline = fopen('data/baseline_pt_ctx_switch.dat','r');
fid_julia    = fopen('data/julia_task_switching.dat','r');

datacell_baseline = textscan(fid_baseline, '%f');
datacell_julia    = textscan(fid_julia, '%f');

fclose(fid_baseline);
fclose(fid_julia);

data(:,1) = datacell_baseline{1};
data(:,2) = datacell_julia{1};
label = {'pthreads';'Julia'};

figure;
boxplot(data, label);
ylabel('latency (ns)');

%% Part II: julia_pmap.dat & julia_parallel_for.dat & baseline_pt_parallel_for.dat & 
%  baseline_omp_parfor. dat :BOXPLOT, CDF
clear all;
fid_julia_pmap     = fopen('data/julia_pmap.dat','r');
fid_julia_parallel = fopen('data/julia_parallel_for.dat','r');
fid_baseline_pt    = fopen('data/baseline_pt_parallel_for.dat','r');
fid_baseline_omp   = fopen('data/baseline_omp_parfor.dat','r');

datacell_julia_pmap     = textscan(fid_julia_pmap, '%f');
datacell_julia_parallel = textscan(fid_julia_parallel, '%f');
datacell_baseline_pt    = textscan(fid_baseline_pt, '%f');
datacell_baseline_omp   = textscan(fid_baseline_omp, '%f');

fclose(fid_julia_pmap);
fclose(fid_julia_parallel);
fclose(fid_baseline_pt);
fclose(fid_baseline_omp);

data(:,1) = datacell_julia_pmap{1};
data(:,2) = datacell_julia_parallel{1};
data(:,3) = datacell_baseline_pt{1};
data(:,4) = datacell_baseline_omp{1};
label = {'Julia pmap'; 'Julia parallel'; 'pthreads'; 'OMP'};

figure;
boxplot(data, label);
ylabel('latency (ns)');

figure;
h(1) = cdfplot(data(:,1));
hold on
h(2) = cdfplot(data(:,2));
h(3) = cdfplot(data(:,3));
h(4) = cdfplot(data(:,4));
set( h(1), 'LineStyle', '-', 'Color', 'k', 'LineWidth', 1.5);
set( h(2), 'LineStyle', '-.', 'Color', 'k', 'LineWidth', 1.5);
set( h(3), 'LineStyle', '--', 'Color', 'k', 'LineWidth', 1.5);
set( h(4), 'LineStyle', ':', 'Color', 'k', 'LineWidth', 1.5);
legend(label, 'Location', 'SouthEast');
title('');
xlabel('latency (ns)');
ylabel('CDF');
hold off;

%% Part III: julia_channel_take & julia_channel_put & julia_channel_fetch & baseline_channels_get & 
%  baseline_channels_put :BOXPLOT, CDF
clear all;
fid_julia_take   = fopen('data/julia_channel_take.dat','r');
fid_julia_put    = fopen('data/julia_channel_put.dat','r');
fid_julia_fetch  = fopen('data/julia_channel_fetch.dat','r');
fid_baseline_get = fopen('data/baseline_channels_get.dat','r');
fid_baseline_put = fopen('data/baseline_channels_put.dat','r');

datacell_julia_take   = textscan(fid_julia_take, '%f');
datacell_julia_put    = textscan(fid_julia_put, '%f');
datacell_julia_fetch  = textscan(fid_julia_fetch, '%f');
datacell_baseline_get = textscan(fid_baseline_get, '%f');
datacell_baseline_put = textscan(fid_baseline_put, '%f');

fclose(fid_julia_take);
fclose(fid_julia_put);
fclose(fid_julia_fetch);
fclose(fid_baseline_get);
fclose(fid_baseline_put);

data(:,1) = datacell_julia_take{1};
data(:,2) = datacell_julia_put{1};
data(:,3) = datacell_julia_fetch{1};
data(:,4) = datacell_baseline_get{1};
data(:,5) = datacell_baseline_put{1};
label = {'Julia take'; 'Julia put'; 'Julia fetch'; 'pthreads get'; 'pthreads put'};

boxplot(data, label);
ylabel('latency (ns)');

figure;
h(1) = cdfplot(data(:,1));
hold on
h(2) = cdfplot(data(:,2));
h(3) = cdfplot(data(:,3));
h(4) = cdfplot(data(:,4));
h(5) = cdfplot(data(:,5));
set( h(1), 'LineStyle', '-', 'Color', 'k', 'LineWidth', 1.5);
set( h(2), 'LineStyle', '-.', 'Color', 'k', 'LineWidth', 1.5);
set( h(3), 'LineStyle', '--', 'Color', 'k', 'LineWidth', 1.5);
set( h(4), 'LineStyle', ':', 'Color', 'k', 'LineWidth', 1.5);
set( h(5), 'LineStyle', '-', 'Marker', '+', 'Color', 'k', 'LineWidth', 1.5);
legend(label, 'Location', 'SouthEast');
title('');
xlabel('latency (ns)');
ylabel('CDF');
hold off;

%% Part IV: julia_notify_condition & baseline_cond : BOXPLOT CDF
clear all;
fid_julia_notify_cond = fopen('data/julia_notify_condition.dat','r');
fid_baseline_cond     = fopen('data/baseline_cond.dat','r');

datacell_julia_notify_cond = textscan(fid_julia_notify_cond, '%f');
datacell_baseline_cond     = textscan(fid_baseline_cond, '%f');

fclose(fid_julia_notify_cond);
fclose(fid_baseline_cond);

data(:,1) = datacell_julia_notify_cond{1};
data(:,2) = datacell_baseline_cond{1};
label = {'Julia';'pthreads'};

boxplot(data, label);
ylabel('latency (ns)');

figure;
h(1) = cdfplot(data(:,1));
hold on
h(2) = cdfplot(data(:,2));
set( h(1), 'LineStyle', '-', 'Color', 'k', 'LineWidth', 1.5);
set( h(2), 'LineStyle', '-.', 'Color', 'k', 'LineWidth', 1.5);
legend(label, 'Location', 'SouthEast');
title('');
xlabel('latency (ns)');
ylabel('CDF');
hold off;