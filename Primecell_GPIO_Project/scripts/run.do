vcd file dump.vcd
vcd add -r /*
run -all

coverage save -codeAll coverage_data.ucdb
coverage report -details -codeAll

quit
