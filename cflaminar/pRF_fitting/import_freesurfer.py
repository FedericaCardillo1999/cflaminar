# %%
import cortex
from cortex import fmriprep
import os
from os import path as op
import shutil
import sys

#####################################################################
# PROCESS MRI DATA USING A COMBINATION OF CORTEX AND FREESURFER 
#####################################################################

# Location of the downloaded Freesurfer dataset
DERIV_PATH = os.getenv('DERIVATIVES')
subject_id = sys.argv[1:][0]
subject = f'sub-{subject_id}'

#####################################################################
# FUNCTION DEFINITION
# COPY_FILES: takes a list of file paths, a source directory and a destination directory and, 
# if the file exists, creates a directory stucture in the destination if it is not there already.
# Finally, it copies each file from the source to the destination directory. 
#####################################################################

# %%
def copy_files(file_list, source_dir, destination_dir):
    for file_name in file_list:
        source_file = os.path.join(source_dir, file_name)
        if not os.path.exists(source_file):
            print(f"Warning: Source file {source_file} does not exist. Skipping.")
            continue
        # Ensure the destination directory structure matches the source
        destination_path = os.path.join(destination_dir, os.path.dirname(file_name))
        os.makedirs(destination_path, exist_ok=True)
        destination_file = os.path.join(destination_dir, os.path.basename(file_name))
        shutil.copyfile(source_file, destination_file)
        print(f"Copied {file_name} to {destination_dir}")
suffix = 'ses-01_acq-MPRAGE'
file_list = [
    f'mri/T1.mgz',
    f'mri/aseg.mgz',
    f'surf/rh.inflated', f'surf/rh.white',
    f'surf/rh.pial', f'surf/rh.smoothwm',
    f'surf/lh.inflated', f'surf/lh.white',
    f'surf/lh.pial', f'surf/lh.smoothwm'] ###  Original Freesurfer Files to be processed. 
new_file_list = [
    f'{subject}_desc-preproc_T1w.mgz', f'{subject}_desc-aseg_dseg.mgz',
    f'{subject}_hemi-R_inflated.surf', f'{subject}_hemi-R_midthickness.surf',
    f'{subject}_hemi-R_pial.surf', f'{subject}_hemi-R_smoothwm.surf',
    f'{subject}_hemi-L_inflated.surf', f'{subject}_hemi-L_midthickness.surf',
    f'{subject}_hemi-L_pial.surf', f'{subject}_hemi-L_smoothwm.surf'] ###  New names for the previous. 

source_dir = f'{DERIV_PATH}/freesurfer/{subject}' ### Freesurfer directory 
temp_dir = f'{DERIV_PATH}/freesurfer/{subject}/temp_anat' ### Temporary directory to hold the copied and renamed files
os.makedirs(temp_dir, exist_ok=True)
copy_files(file_list, source_dir, temp_dir)


##### FILE RENAMING LOOP
##### For each file in the file liest, rename it corresponding to the new names. 
for i in range(len(file_list)):
    try:
        old_file_path = os.path.join(temp_dir, os.path.basename(file_list[i]))
        if not os.path.exists(old_file_path):
            print(f"Error: File {file_list[i]} not found.")
            continue
        new_file_path = os.path.join(temp_dir, new_file_list[i])
        os.rename(old_file_path, new_file_path)
        print(f"Renamed {file_list[i]} to {new_file_list[i]}")
    except FileExistsError:
        print(f"Error: File {new_file_list[i]} already exists.")

# %%
# Import subject into pycortex database from Freesurfer
cortex.freesurfer.import_subj(f'sub-{subject_id}', freesurfer_subject_dir=f'{DERIV_PATH}/freesurfer')

# %%
# Copy fiducial surfaces for proper visualization
import cortex.database
pycortex_db = cortex.database.default_filestore

shutil.copyfile(f'{pycortex_db}/{subject_id}/surfaces/fiducial_lh.gii', f'{pycortex_db}/sub-{subject_id}/surfaces/fiducial_lh.gii')
shutil.copyfile(f'{pycortex_db}/{subject_id}/surfaces/fiducial_rh.gii', f'{pycortex_db}/sub-{subject_id}/surfaces/fiducial_rh.gii')