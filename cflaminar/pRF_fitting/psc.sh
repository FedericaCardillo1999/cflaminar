#!/bin/bash
#SBATCH --time=02:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=25
#SBATCH --job-name=psc
#SBATCH --mem=10GB
#SBATCH --output=/scratch/hb-EGRET-AAA/psc.out
#SBATCH --error=/scratch/hb-EGRET-AAA/psc.err

# Load environment
source /home2/p315561/venvs/preproc/bin/activate 
source ~/.bash_profile

python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 02 02 RET 6 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 04 02 RET 6 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 05 02 RET 6 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 06 01 RET 6 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 07 02 RET 6 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 08 02 RET 6 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 09 02 RET 6 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 10 02 RET 6 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 11 02 RET 6 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 12 02 RET 6 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 13 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 14 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 15 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 16 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 17 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 18 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 19 02 RET 6 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 20 02 RET 4 nordic

python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 21 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 22 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 23 02 RET 6 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 25 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 26 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 27 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 28 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 29 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 30 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 31 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 32 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 33 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 34 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 35 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 36 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 37 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 38 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 39 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 40 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 41 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 42 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 43 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 44 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 45 02 RET 4 nordic
python /home2/p315561/programs/cflaminar/pRF_fitting/psc_GM_RHLH.py 46 02 RET 4 nordic