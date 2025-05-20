#!/usr/bin/env python
# %%
import numpy as np
import matplotlib.pyplot as plt
import nibabel as nib
import os
import sys
from scipy import signal

# %%
#args: subject, session, task, nruns, denoising

subject=f'sub-{sys.argv[1:][0]}'
session=sys.argv[2:][0]
task=sys.argv[3:][0]
nruns=int(sys.argv[4:][0])
#MAIN_PATH=os.getenv("DERIVATIVES")
project=os.getenv("PROJECT")
resampling='resampled'
denoising=sys.argv[5:][0]
filter=1
depth_list=['GM']

MAIN_PATH = '/scratch/hb-EGRET-AAA/projects/EGRET+/derivatives'

for depth in range(len(depth_list)):
    proc_tc_RH = []  # Store the time course for the Right Hemisphere
    proc_tc_LH = []  # Store the time course for the Left Hemisphere

    for run in range(nruns):
        # Load GIFTI files
        proc_tc_L = nib.load(
            f'{MAIN_PATH}/{resampling}/{subject}/ses-{session}/{denoising}/{subject}_ses-{session}_task-{task}_run-{run + 1}_space-fsnative_hemi-L_desc-{denoising}_bold_GM.gii')
        proc_tc_R = nib.load(
            f'{MAIN_PATH}/{resampling}/{subject}/ses-{session}/{denoising}/{subject}_ses-{session}_task-{task}_run-{run + 1}_space-fsnative_hemi-R_desc-{denoising}_bold_GM.gii')

        tc_R = proc_tc_R.agg_data().T
        tc_L = proc_tc_L.agg_data().T

        # Clip if not RestingState
        if task != 'RestingState':
            if tc_R.shape[0] > 136:
                tc_R = tc_R[:136, :]
            if tc_L.shape[0] > 136:
                tc_L = tc_L[:136, :]

        # Normalize with nanmean
        mean_R = np.nanmean(tc_R, axis=0)
        mean_R[mean_R == 0] = np.nan
        scale_R = 100 / mean_R
        scale_R = np.nan_to_num(scale_R, nan=0.0, posinf=0.0, neginf=0.0)
        tc_m_R = tc_R * scale_R[np.newaxis, :]
        tc_m_R = np.nan_to_num(tc_m_R, nan=0.0, posinf=0.0, neginf=0.0)

        mean_L = np.nanmean(tc_L, axis=0)
        mean_L[mean_L == 0] = np.nan
        scale_L = 100 / mean_L
        scale_L = np.nan_to_num(scale_L, nan=0.0, posinf=0.0, neginf=0.0)
        tc_m_L = tc_L * scale_L[np.newaxis, :]
        tc_m_L = np.nan_to_num(tc_m_L, nan=0.0, posinf=0.0, neginf=0.0)

        # Baseline correction
        baseline_R = np.median(tc_m_R[:5], axis=0)
        baseline_L = np.median(tc_m_L[:5], axis=0)
        tc_m_R = tc_m_R - baseline_R
        tc_m_L = tc_m_L - baseline_L

        # Optional filtering
        if filter == 1:
            mean_R = np.mean(tc_m_R, axis=0)
            mean_L = np.mean(tc_m_L, axis=0)
            tc_m_R = signal.detrend(tc_m_R, axis=0) + mean_R
            tc_m_L = signal.detrend(tc_m_L, axis=0) + mean_L

            TR = 1.5
            fs = 1 / TR
            lowcut = 0.006
            nyquist = 0.5 * fs
            f_low = lowcut / nyquist
            sos = signal.butter(8, [f_low], 'highpass', fs=fs, output='sos')
            tc_m_R = signal.sosfiltfilt(sos, tc_m_R, axis=0)
            tc_m_L = signal.sosfiltfilt(sos, tc_m_L, axis=0)

        proc_tc_RH.append(tc_m_R)
        proc_tc_LH.append(tc_m_L)

    mean_proc_tc_RH = np.median(np.array(proc_tc_RH), axis=0)
    mean_proc_tc_LH = np.median(np.array(proc_tc_LH), axis=0)

    path = f'{MAIN_PATH}/pRFM/{subject}/ses-{session}/{denoising}/'
    os.makedirs(path, exist_ok=True)
    np.save(f'{path}{subject}_ses-{session}_task-{task}_hemi-rh_desc-avg_bold_GM.npy', mean_proc_tc_RH)
    np.save(f'{path}{subject}_ses-{session}_task-{task}_hemi-lh_desc-avg_bold_GM.npy', mean_proc_tc_LH)
