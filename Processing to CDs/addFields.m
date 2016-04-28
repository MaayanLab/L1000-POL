function [chdir] = addFields(chdir,proto)
    chdir.batch = proto.batch;
    chdir.pert_id = proto.pert_id;
    chdir.pert_dose = proto.pert_dose;
    
    if isfield(proto,'pert_desc')
        chdir.pert_desc = proto.pert_desc;
    else
        chdir.pert_iname = proto.pert_iname;
    end
    chdir.pert_type = proto.pert_type;
    chdir.pert_time = proto.pert_time;
    chdir.pert_time_unit = proto.pert_time_unit;
    chdir.pert_dose_unit = proto.pert_dose_unit;
    chdir.cell_id = proto.cell_id;
   
end