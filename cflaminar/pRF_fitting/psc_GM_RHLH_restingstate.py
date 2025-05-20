import numpy as np
import nibabel as nib
import os
import sys
from scipy import signal

# =========================
# CONFIGURATION & SETTINGS
# =========================
MAIN_PATH = '/scratch/hb-EGRET-AAA/projects/EGRET+/derivatives'
RESAMPLING = 'resampled'
TASK = 'RestingState'
FILTER_ENABLED = True
DEPTH_LIST = ['GM']

# Filtering parameters
TR = 1.5
FS = 1 / TR
LOWCUT = 0.006
HIGHCUT = 0.015
NYQUIST = 0.5 * FS
F_LOW = LOWCUT / NYQUIST

# =========================
# INPUT ARGUMENTS
# =========================
subject = f'sub-{sys.argv[1]}'
session = sys.argv[2]
nruns = int(sys.argv[3])
denoising = sys.argv[4]

# =========================
# PROCESSING LOOP
# =========================
for depth in DEPTH_LIST:
    for run in range(1, nruns + 1):
        # --- Load Left & Right Hemisphere Timecourses ---
        file_base = f'{MAIN_PATH}/{RESAMPLING}/{subject}/ses-{session}/{denoising}/{subject}_ses-{session}_task-{TASK}_run-{run}_space-fsnative'
        tc_L = nib.load(f'{file_base}_hemi-L_desc-{denoising}_bold_GM.gii').agg_data()
        tc_R = nib.load(f'{file_base}_hemi-R_desc-{denoising}_bold_GM.gii').agg_data()

        # --- Combine Hemispheres ---
        tc = np.vstack([tc_L, tc_R]).T

        # --- Scale Timecourse ---
        mean_tc = np.nanmean(tc, axis=0)
        mean_tc[(mean_tc == 0) | np.isnan(mean_tc)] = np.nan
        scale_factor = np.nan_to_num(100 / mean_tc)
        tc_m = tc * np.expand_dims(scale_factor, axis=0)

        # --- Handle NaNs ---
        if np.isnan(tc_m).any():
            nan_count = np.isnan(tc_m).sum()
            total_elements = tc_m.size
            print(f'Run {run} | {nan_count} NaNs after scaling ({(nan_count / total_elements) * 100:.2f}%). Replacing with zeros.')
            tc_m = np.nan_to_num(tc_m)

        # --- Baseline Correction ---
        baseline = np.nanmedian(tc_m[:5], axis=0)
        tc_m -= baseline

        # --- Filtering ---
        if FILTER_ENABLED:
            mean = np.mean(tc_m, axis=0)
            tc_m = signal.detrend(tc_m, axis=0) + mean
            sos = signal.butter(8, [F_LOW], 'highpass', fs=FS, output='sos')
            tc_m = signal.sosfiltfilt(sos, tc_m, axis=0)

        # --- Split Back into LH and RH ---
        n_vertices = tc_L.shape[0]
        tc_m_LH = tc_m[:, :n_vertices]
        tc_m_RH = tc_m[:, n_vertices:]

        # --- Save Outputs ---
        output_dir = f'{MAIN_PATH}/pRFM/{subject}/ses-02/{denoising}/'
        os.makedirs(output_dir, exist_ok=True)

        np.save(f'{output_dir}{subject}_ses-02_task-{TASK}_run-{run}_hemi-lh_desc-avg_bold_{depth}.npy', tc_m_LH)
        np.save(f'{output_dir}{subject}_ses-02_task-{TASK}_run-{run}_hemi-rh_desc-avg_bold_{depth}.npy', tc_m_RH)
        np.save(f'{output_dir}{subject}_ses-02_task-{TASK}_run-{run}_hemi-LR_desc-avg_bold_{depth}.npy', tc_m)

        print(f'✅ Run {run}: Saved LH, RH, and combined timecourses.')

