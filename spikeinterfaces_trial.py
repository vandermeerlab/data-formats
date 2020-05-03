import spikeinterface.extractors as se
import spikeinterface.toolkit as st
import spikeinterface.sorters as ss
import spikeinterface.comparison as sc
import spikeinterface.widgets as sw
# Additional imports
import os.path as op
import neo  # neo for some direct reading to check on # of segments etc

sample_file = '/Users/manishm/Work/vanDerMeerLab/NWB/data/MotivationalT-v2/R050/R050-2014-03-31_raw/R050-2014-03-31-TT04.ntt'
dname = (op.dirname(sample_file))
# reader = neo.NeuralynxIO(dirname=dname)
recording = se.NeuralynxRecordingExtractor(dirname=op.dirname(sample_file), seg_index=0)
klusta_out = ss.run_klusta(recording, output_folder="temp")