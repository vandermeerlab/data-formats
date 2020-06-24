

# Recommended import aliases: https://spikeinterface.readthedocs.io/en/latest/getting_started/plot_getting_started.html
import spikeinterface.extractors as se
import spikeinterface.sorters as ss
# Additional imports
import os.path as op
import neo  # neo for some direct reading to check on # of segments etc
import numpy as np
import matplotlib.pyplot as plt
import os


sample_file1 = 'data\BiconditionalOdor\M040-2020-04-29-CDOD12\CSC12.ncs'
dname1 = (op.dirname(sample_file1))
# print(dname1)



#Throws an error if the the ncs files don't have the same length
#On omitting the file with a different length, this works (M40-2020-04-28-CDOD11/CSC26.ncs for instance)
reader1 = neo.NeuralynxIO(dirname=dname1)


#
# print(reader1)
#
#
#
# reader1.nse_ntt_filenames



ntt_channel_id_name = {}
for key,value in reader1.nse_ntt_filenames:
    ntt_channel_id_name[value] = key
# print(ntt_channel_id_name)



ncs_channel_name_id = {}
ncs_channel_id_name = {}
for key,value in reader1.ncs_filenames:
    ncs_channel_name_id[key] = value
    ncs_channel_id_name[value] = key
# print(ncs_channel_name_id)
# print(ncs_channel_id_name)



ntt_ncs_map = {}
for key in ntt_channel_id_name.keys():
    if ntt_channel_id_name[key] in ntt_ncs_map:
        ntt_ncs_map[ntt_channel_id_name[key]].append(ncs_channel_id_name[key])
    else:
        ntt_ncs_map[ntt_channel_id_name[key]] = []
        ntt_ncs_map[ntt_channel_id_name[key]].append(ncs_channel_id_name[key])
# print (ntt_ncs_map)



recordingList = [se.NeuralynxRecordingExtractor(dirname=op.dirname(sample_file1), seg_index=i) for i in range(reader1.segment_count(0))]
recordingFull = se.MultiRecordingTimeExtractor(recordingList)



location_keys_1 = [6,1,8,3];
location_keys_2 = [5,2,7,4];
seed1 = np.array([0, 0])
seed2 = np.array([0,150])
x_offset = np.array([200,0])
location_values_1 = [seed1, seed1+([-25/np.sqrt(2),25/np.sqrt(2)]), seed1+np.array([25/np.sqrt(2),25/np.sqrt(2)]), seed1+np.array([0,50/np.sqrt(2)])]
location_values_2 = [seed2, seed2+([-25/np.sqrt(2),25/np.sqrt(2)]), seed2+np.array([25/np.sqrt(2),25/np.sqrt(2)]), seed2+np.array([0,50/np.sqrt(2)])]
for i in range(3):
    location_keys_1.extend([location_keys_1[j]+8*(i+1) for j in range(4)])
    location_values_1.extend(location_values_1[j]+x_offset*(i+1) for j in range(4))
    location_keys_2.extend([location_keys_2[j]+8*(i+1) for j in range(4)])
    location_values_2.extend(location_values_2[j]+x_offset*(i+1) for j in range(4))
# print (location_keys_1)
# print (location_keys_2)
location_name_keys = location_keys_1 + location_keys_2
location_name_keys = ['CSC'+str(x) for x in location_name_keys]
location_values = location_values_1 + location_values_2
# print(location_name_keys, location_values)
location_dict = {}
for i in range(len(location_name_keys)):
    location_dict[location_name_keys[i]] = location_values[i]
# print(location_dict)


#
# xcoords = [pos[0] for pos in location_values]
# ycoords = [pos[1] for pos in location_values]
# fig,ax = plt.subplots()
# ax.axis('off')
# for i in range(len(xcoords)):
#     plt.text(xcoords[i]/200,ycoords[i]/200,location_name_keys[i])




channel_ids = recordingFull.get_channel_ids()
group_ids = [int(ntt_channel_id_name[channel_ids[i]][2:]) for i in range(len(channel_ids))]
# print(group_ids)
recordingFull.set_channel_groups(group_ids)
channel_locs = np.array([location_dict[ncs_channel_id_name[channel_ids[i]]] for i in range(len(channel_ids))])
# print (channel_locs)
recordingFull.set_channel_locations(channel_locs)


#
# xcoords = [pos[0] for pos in channel_locs]
# ycoords = [pos[1] for pos in channel_locs]
# fig,ax = plt.subplots()
# ax.axis('off')
# for i in range(len(xcoords)):
#     plt.text(xcoords[i]/200,ycoords[i]/200,ncs_channel_id_name[channel_ids[i]])



# l1 = dir(recordingList[0])
# l2 = dir(recordingFull)
# uq1 = [x for x in l1 if not x in l2]
# uq2 = [x for x in l2 if not x in l1]
# print(uq1)
# print(uq2)
#
#
#
# print (ss.available_sorters())



ks2_params = ss.Kilosort2Sorter.default_params()
# print(dir(ss.Kilosort2Sorter))



# print(ks2_params)



ss.Kilosort2Sorter.installation_mesg



ss.Kilosort2Sorter.set_kilosort2_path('D:\AutomaticSpikeSort\Kilosort2')



ss.Kilosort2Sorter.installed



os.chdir('C:/Users/mvdmlab')







ks2_out0 = ss.run_kilosort2(recordingFull, output_folder = 'C:/Users/mvdmlab/ks2_test_without_group')
ks2_out1 = ss.run_kilosort2(recordingFull, output_folder = 'C:/Users/mvdmlab/ks2_test_with_group', grouping_property='group' )
# Does not work if the working folder is in a different drive
# ks2_out1 = ss.run_sorters(['kilosort2'],[recordingFull], working_folder='C:/Users/mvdmlab/ss_ks2test')


