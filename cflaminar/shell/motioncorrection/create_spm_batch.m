function create_spm_batch(subject, session, task)
% Create SPM Batch for Realignment and Estimation
% Automatically counts the number of runs for the specified task and generates
% the corresponding batch file.

% To run the following script, open the terminal window and copy this command:
% Arguemnts should be 'subject number', 'session number', 'task name' 
% matlab -nodisplay -nosplash -r "cd('/home2/p315561/programs/cflaminar/shell'); create_spm_batch('10', '02', 'RET2'); exit;"

% Initialize SPM
addpath(genpath('/home2/p315561/programs/spm12')); % Add SPM to MATLAB path 
spm('defaults', 'FMRI');                           % Set SPM defaults for fMRI analysis
spm_jobman('initcfg');                             % Initialize SPM job manager

% Define the base directory for the task
base_dir = '/scratch/hb-EGRET-AAA/projects/EGRET+/sub-%s/ses-%s/func/';
base_dir = sprintf(base_dir, subject, session);

% Detect the number of runs for the specified task
run_files = dir(fullfile(base_dir, sprintf('sub-%s_ses-%s_task-%s_run-*_bold.nii.gz', subject, session, task)));
num_runs = numel(run_files);

% Construct paths to the NIfTI files dynamically based on detected runs
nifti_files = cell(num_runs, 1);
for i = 1:num_runs
    nifti_files{i} = fullfile(run_files(i).folder, run_files(i).name);
    fprintf('Adding file to batch: %s\n', nifti_files{i});
end

% Create the batch structure for SPM
matlabbatch{1}.spm.spatial.realign.estwrite.data = nifti_files';
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 3;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 3;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

% Save the batch configuration to a .mat file
output_file = sprintf('/home2/p315561/programs/cflaminar/shell/batch_spmmoco_%druns.mat', num_runs);
save(output_file, 'matlabbatch'); % Save the batch to the specified file