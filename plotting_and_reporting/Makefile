
all: context-switches task-creations spawn-fetch ping-pong cond-plot

context-switches: data/context-switches/julia_ctx_switch.dat data/context-switches/c_ctx_switch.dat context_switch_plot.py
	python3 ./context_switch_plot.py

task-creations: data/task-creations/c_task_create_tput.dat data/task-creations/julia_task_create_tput.dat task_creation_tput_plot.py
	python3 ./task_creation_tput_plot.py

ping-pong: data/pingpong/c_and_julia/* data/pingpong/c_and_julia_opt/* pingpong_lineplot.py
	python3 ./pingpong_lineplot.py

spawn-fetch: data/spawn-fetch/spawn_fetch.csv spawn_fetch_grouped_bar.py
	python3 ./spawn_fetch_grouped_bar.py

condvars: data/condvar/*.dat cond_plot.py
	python3 ./cond_plot.py

clean:
	@rm -f *.pdf

.PHONY: all clean
