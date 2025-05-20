#!/bin/bash
#SBATCH --time=02:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=25
#SBATCH --mem=20GB

module load FSL/6.0.5.1-foss-2021a
module load ANTs/2.5.0-foss-2022b
module load AFNI

for i in $(seq -w 02 46); do
    if [[ "$i" == "03" || "$i" == "24" ]]; then
        echo "⏭️ Skipping sub-${i}"
        continue
    fi

    subj="sub-${i}"
    echo "🔄 Processing $subj..."

    base_directory="/scratch/hb-EGRET-AAA/projects/EGRET+/${subj}"
    coreg_directory="/scratch/hb-EGRET-AAA/projects/EGRET+/derivatives/coreg/${subj}"

    mprage_input=$(find "${coreg_directory}/ses-01/anat/" -iname "*MPRAGE*_T1w.nii*" | grep -i "${subj}_ses-01" | head -n 1)

    if [[ ! -f "$mprage_input" ]]; then
        echo "❌ MPRAGE not found for $subj. Skipping..."
        continue
    fi

    # ---------------------------------------------------------------------
    #  FIND THE RestingState BOLDref  (run‑1)  in ses‑01 *or* ses‑02
    epi_ref=$(find "${coreg_directory}" \
            -path "*/func/*" \
            -iname "${subj}_ses-0[12]_task-RestingState_run-1_boldref.nii*" \
            | sort | head -n 1)

    if [[ -z "$epi_ref" || ! -f "$epi_ref" ]]; then
        echo "❌ No RestingState boldref found in ses‑01 or ses‑02 for $subj – skipping."
        continue
    fi

    # Extract the session we actually found (01 or 02) so later paths match
    found_ses=$(echo "$epi_ref" | sed -E 's/.*_ses-0([12])_.*/\1/')

    echo "📂 Using BOLDref from ses‑0${found_ses}: $epi_ref"


    mprage_cropped="${coreg_directory}/ses-01/anat/MPRAGE.nii.gz"
    transformed_epi="${coreg_directory}/ses-01/anat/boldref_in_MPRAGE.nii.gz"
    transform_prefix="${coreg_directory}/ses-01/anat/epi2mprage_"
    transform_file="${transform_prefix}0GenericAffine.mat"

    echo "🧠 Running robustfov for $subj"
    robustfov -i "$mprage_input" -r "$mprage_cropped"

    echo "🧭 Running antsRegistration..."
    antsRegistration --verbose 1 \
        --dimensionality 3 \
        --float 0 \
        --interpolation Linear \
        --use-histogram-matching 0 \
        --winsorize-image-intensities [0.005,0.995] \
        --output [${transform_prefix},${transform_prefix}Warped.nii.gz,${transform_prefix}InverseWarped.nii.gz] \
        --initial-moving-transform [${mprage_cropped},${epi_ref},1] \
        --transform Rigid[0.1] \
        --metric MI[${mprage_cropped},${epi_ref},1,32,Random,0.25] \
        --convergence [500x250x50,1e-6,10] \
        --shrink-factors 2x2x1 \
        --smoothing-sigmas 2x1x0vox

    if [[ -f "$transform_file" ]]; then
        echo "📌 Applying transform to BOLDref..."
        antsApplyTransforms \
            -d 3 \
            -i "$epi_ref" \
            -r "$mprage_cropped" \
            -t "$transform_file" \
            -o "$transformed_epi" \
            -n BSpline[5]
        echo "✅ BOLDref aligned for $subj"
    else
        echo "❌ Transform not found for $subj. Skipping application."
        continue
    fi

    echo "🎯 Applying transform to RestingState runs only..."

    run_dir="${coreg_directory}/ses-${found_ses}/func"
    output_func_dir="/scratch/hb-EGRET-AAA/projects/EGRET+/${subj}/ses-0${found_ses}/func"

    for run_file in "${run_dir}/${subj}_ses-${found_ses}_task-RestingState_run-"*_bold.nii.gz; do
        [[ -e "$run_file" ]] || continue

        run_name=$(basename "$run_file")
        output_file="${run_file%.nii.gz}_transformed.nii.gz"
        final_dest="${output_func_dir}/$(basename "$run_file")"

        echo "🔄 Transforming $run_name"
        antsApplyTransforms \
            -d 3 -e 3 \
            -i "$run_file" \
            -r "$transformed_epi" \
            -t "$transform_file" \
            -o "$output_file" \
            -n Linear \
            -v 1

        cp "$output_file" "$final_dest"
        echo "✅ Transformed and copied: $(basename "$final_dest")"
    done

    echo "✅ Done with $subj"
    echo "--------------------------------------------"

    echo "🧪 Opening ITK-SNAP to visually inspect alignment..."
    #echo "🔎 Checking for transformed RestingState runs in ${output_func_dir}:"
    #ls -lh "${output_func_dir}" | grep "RestingState_run"

    # Correct filenames: these are the *transformed* outputs, not the originals
    #resting1="${output_func_dir}/${subj}_ses-0${found_ses}_task-RestingState_run-1_bold.nii.gz"
    #resting2="${output_func_dir}/${subj}_ses-0${found_ses}_task-RestingState_run-2_bold.nii.gz"

    #overlay_opts=()
    #[[ -f "$resting1" ]] && overlay_opts+=(-o "$resting1")
    #[[ -f "$resting2" ]] && overlay_opts+=(-s "$resting2")

    #if [[ ${#overlay_opts[@]} -gt 0 ]]; then

    #    echo "🧪 Launching ITK-SNAP... (close it to continue to next subject)"
    #    itk-snap -g "$mprage_cropped" "${overlay_opts[@]}"

    #else
    #    echo "⚠️ No transformed RestingState runs found for ITK-SNAP visualization."
    #fi



done