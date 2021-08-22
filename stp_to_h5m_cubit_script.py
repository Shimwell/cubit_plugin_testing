import sys
from pathlib import Path

cubit_path='/opt/Coreform-Cubit-2021.5/bin/'  # this could be an argument to test multiple versions
sys.path.append(cubit_path)
import cubit
cubit.init([])


faceting_tolerance=1.0e-2
merge_tolerance=1e-4


cubit.cmd("set attribute on")

# loads stp files into cubit
filename = 'stp_files/blanket.stp'
cubit.cmd(f"import step '{filename}' separate_bodies no_surfaces no_curves no_vertices")

filename = 'stp_files/outboard_firstwall.stp'
cubit.cmd(f"import step '{filename}' separate_bodies no_surfaces no_curves no_vertices")

# applies material tags
cubit.cmd('group "mat:m1 add volume 1')
cubit.cmd('group "mat:m2 add volume 2')

# imprints and merge the geometry
cubit.cmd("imprint body all")
cubit.cmd("merge tolerance " + str(merge_tolerance))  # optional as there is a default
cubit.cmd("merge vol all group_results")


cubit.cmd('export dagmc "dagmc.h5m" faceting_tolerance '+ str(faceting_tolerance) + ' make_watertight')

# raises and AssertError if file does not exist
assert Path('dagmc.h5m').is_file()
