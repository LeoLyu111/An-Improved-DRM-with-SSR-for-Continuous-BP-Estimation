function[feature_person,position_features]= feature_collect (BP,PPG,len_index,statistic,RpeakIndex_ECG,systolicIndex_BP,footIndex_BP,insert_all_indexs,systolicIndex_PPG,footIndex_PPG,dicroticIndex_PPG,notchIndex_PPG)
movemedian_window=10;
for (k=[1:1:max(statistic)])
            % here the SBP, DBP and MBP contain all the SBP, DBP and MBP
            SBP_origin(k,1)=BP(systolicIndex_BP(1,k));
            DBP_origin(k,1)=BP(footIndex_BP(1,k));
end
        SBP_movemedian=movmedian(SBP_origin, movemedian_window);
        DBP_movemedian=movmedian(DBP_origin, movemedian_window);
        for (k=[1:1:max(statistic)])
            %name_cell2={'RpeakIndex-ECG','footIndex-BP','footIndex-PPG','systolicIndex-BP','systolicIndex-PPG'};
            if ismember(systolicIndex_BP(1,k),insert_all_indexs{4,1})
                SBP(k,1)=SBP_movemedian(k,1);
            else
                SBP(k,1)=SBP_origin(k,1);
            end
            if ismember(footIndex_BP(1,k), insert_all_indexs{2,1})
                DBP(k,1)=DBP_movemedian(k,1);
            else
                DBP(k,1)=DBP_origin(k,1);
            end
            MBP(k,1)=2/3*DBP(k,1)+1/3*SBP(k,1);
        end 
% in this step, SBP.DBP and MBP for each beat are calculated
%%========================================================
        if max(footIndex_PPG)>length(BP)
         footIndex_PPG(len_index)=length(BP);
    end
      if max(systolicIndex_PPG)>length(BP)
         systolicIndex_PPG(len_index)=length(BP);
      end
         if max(dicroticIndex_PPG)>length(BP)
         dicroticIndex_PPG(len_index)=length(BP);
         end

 %%========================================================
 
        for(k=[1:1:max(statistic)])
            %% Time indeces (7 features)
            PTTp(k,1)=systolicIndex_PPG(1,k)-RpeakIndex_ECG(1,k);
            PTTf(k,1)=footIndex_PPG(1,k)-RpeakIndex_ECG(1,k);
            Up_time(k,1)=systolicIndex_PPG(1,k)-footIndex_PPG(1,k);
            Bf_time(k,1)=notchIndex_PPG(1,k)-footIndex_PPG(1,k);
            Down_time(k,1)=dicroticIndex_PPG(1,k)-systolicIndex_PPG(1,k);
%             Fb_time(k,1)=footIndex_PPG(1,k+1)-notchIndex_PPG(1,k);
%             Bb_time(k,1)=footIndex_PPG(1,k+1)-footIndex_PPG(1,k);
            %% Dlope indeces (3 features)
            Cf_slope(k,1)=abs(PPG(1,notchIndex_PPG(1,k))-PPG(1,footIndex_PPG(1,k)))/(abs(Bf_time(k,1)));
            Bc_slope(k,1)=abs(PPG(1,systolicIndex_PPG(1,k))-PPG(1,footIndex_PPG(1,k)))/(abs(Up_time(k,1)));
            Cb_slope(k,1)=abs(PPG(1,systolicIndex_PPG(1,k))-PPG(1,dicroticIndex_PPG(1,k)))/(abs(Down_time(k,1)));
            %% Area indeces (4 features)
            Systolic_volume(k,1)=1/200 * trapz(PPG(footIndex_PPG(1,k):1:systolicIndex_PPG(1,k)));
            Systolic_notch_volume(k,1)=1/200 * trapz(PPG(systolicIndex_PPG(1,k):1:notchIndex_PPG(1,k)));
            Notch_diastolic_volume(k,1)=1/200 * trapz(PPG(notchIndex_PPG(1,k):1:dicroticIndex_PPG(1,k)));
%             Diastolic_volume(k,1)=1/200 * trapz(PPG(systolicIndex_PPG(1,k):1:footIndex_PPG(1,k+1)));
            %% Intensity indeces (4 features)
            Systolic_dicrotic_RI(k,1)=abs(PPG(1,systolicIndex_PPG(1,k))/PPG(1,dicroticIndex_PPG(1,k)));
            Systolic_foot_RI(k,1)=abs(PPG(1,systolicIndex_PPG(1,k))/PPG(1,footIndex_PPG(1,k)));
            Systolic_notch_RI(k,1)=abs(PPG(1,systolicIndex_PPG(1,k))/PPG(1,notchIndex_PPG(1,k)));
            Dicrotic_notch_RI(k,1)=abs(PPG(1,dicroticIndex_PPG(1,k))/PPG(1,notchIndex_PPG(1,k)));
            %% specifical indeces (1 feature)
            if(k~=max(statistic))
                Fb_time(k,1)=footIndex_PPG(1,k+1)-notchIndex_PPG(1,k);
                Bb_time(k,1)=footIndex_PPG(1,k+1)-footIndex_PPG(1,k);
                Diastolic_volume(k,1)=1/200 * trapz(PPG(systolicIndex_PPG(1,k):1:footIndex_PPG(1,k+1)));
                HR(k,1)=1/(RpeakIndex_ECG(1,k+1)-RpeakIndex_ECG(1,k));
            else
                Fb_time(k,1)=Fb_time(k-1,1);
                Bb_time(k,1)=Bb_time(k-1,1);
                Diastolic_volume(k,1)=Diastolic_volume(k-1,1);
                HR(k,1)=HR(k-1,1);
            end
        end
%%============================================================
        segment=[];
        PTTp=PTTp(1:len_index-1);
        PTTf=PTTf(1:len_index-1);
        Up_time=Up_time(1:len_index-1);
        Bf_time=Bf_time(1:len_index-1);
        Down_time=Down_time(1:len_index-1);
        Fb_time=Fb_time(1:len_index-1);
        Bb_time=Bb_time(1:len_index-1);

        Cf_slope=Cf_slope(1:len_index-1);
        Bc_slope=Bc_slope(1:len_index-1);
        Cb_slope=Cb_slope(1:len_index-1);

        Systolic_volume=Systolic_volume(1:len_index-1);
        Systolic_notch_volume=Systolic_notch_volume(1:len_index-1);
        Notch_diastolic_volume=Notch_diastolic_volume(1:len_index-1);
        Diastolic_volume=Diastolic_volume(1:len_index-1);

        Systolic_dicrotic_RI=Systolic_dicrotic_RI(1:len_index-1);
        Systolic_foot_RI=Systolic_foot_RI(1:len_index-1);
        Systolic_notch_RI=Systolic_notch_RI(1:len_index-1);
        Dicrotic_notch_RI=Dicrotic_notch_RI(1:len_index-1);

        HR=HR(1:len_index-1);
        SBP=SBP(1:len_index-1);
        DBP=DBP(1:len_index-1);
        MBP=MBP(1:len_index-1);
        position_features=horzcat(RpeakIndex_ECG',footIndex_PPG',systolicIndex_PPG',notchIndex_PPG',dicroticIndex_PPG');

%         feature_person=horzcat(PTTp,PTTf,Up_time,Bf_time,Down_time,Fb_time,Bb_time,Cf_slope,Bc_slope,Cb_slope,Systolic_volume,Systolic_notch_volume,Notch_diastolic_volume,Diastolic_volume,Systolic_dicrotic_RI,Systolic_foot_RI,Systolic_notch_RI,Dicrotic_notch_RI,HR,SBP,DBP,MBP);
        feature_person=horzcat(PTTp,Cf_slope,Systolic_notch_volume,Systolic_foot_RI,HR,SBP,DBP,MBP);

end