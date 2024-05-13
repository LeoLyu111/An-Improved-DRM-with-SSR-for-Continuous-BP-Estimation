function[feature_person,position_features]=Extract_feature(signal)

% setting
disp_original_BP_ECG_PPG=0; % 0 not display, 1 display
disp_BP_PPG_ECG_annotation=0; % 0 not display, 1 display
movemedian_window=10; % number of elements considered for outlier detection and missing data filling
tolerance=0.2; % for determination of number of misssing timestep
shift_beats=4; % the number of beats of shift of two ajacent sample, when shift_beats==sample_beats, samples are unoverlapped
sample_beats=16; % the number of beats in one sample



        PPG=signal(1,:);
        BP=signal(2,:);       
        ECG=signal(3,:);
              ECG=ECG(31:end);


        fs=125; % here original frequency is 200 Hz
        
        % display original BP, ECG and PPG
        summary=horzcat(BP,ECG,PPG);
        len_summary=size(summary,1);
        name_cell1={'BP','ECG','PPG'};
        if(disp_original_BP_ECG_PPG)
            figure;
            for k=[1:1:3]
                ax(k)=subplot(3,1,k);
                plot([1:1:len_summary],summary(:,k));
                ylabel(name_cell1{k});
                xlabel('time')
            end
            linkaxes(ax,'x');
        end

        % find the foots and peaks of BP, ECG and PPG
        % here all are 200Hz
        disp('Detecting ECG...');
        [qrs_amp_raw,RpeakIndex_ECG,delay]=pan_tompkin(ECG,125,disp_BP_PPG_ECG_annotation);
        disp('Done.');
        [ footIndex_BP, systolicIndex_BP, notchIndex_BP, dicroticIndex_BP ] = ...
         BP_annotate( BP, 125, disp_BP_PPG_ECG_annotation, 'unknown', 1);
        [ footIndex_PPG, systolicIndex_PPG, notchIndex_PPG, dicroticIndex_PPG ] = ...
         PPG_annotate( PPG, 125, disp_BP_PPG_ECG_annotation, 'unknown', 1);

        % delete repeat value
        time_markers={RpeakIndex_ECG, ...
            footIndex_BP, footIndex_PPG, systolicIndex_BP, systolicIndex_PPG,...
            notchIndex_BP, notchIndex_PPG, dicroticIndex_BP, dicroticIndex_PPG};
        for (k=[1:1:9])
            time_markers{1,k}=unique(time_markers{1,k});
        end

        % detect outlier, determine missing timestep, fill missing data (1)
        % total_index_data={RpeakIndex_ECG,footIndex_BP,footIndex_PPG,systolicIndex_BP,systolicIndex_PPG,notchIndex_BP,notchIndex_PPG,dicroticIndex_BP,dicroticIndex_PPG};
        name_cell2={'RpeakIndex-ECG','footIndex-BP','footIndex-PPG','systolicIndex-BP','systolicIndex-PPG','notchIndex-BP','notchIndex-PPG','dicroticIndex-BP','dicroticIndex-PPG'};
        type={2,1,3,1,3,1,3,1,3 }; %1:BP, 2:ECG, 3:PPG   
        for(i=[1:1:9])
            index_data_name=name_cell2{i};  
            original_data=summary(:,type{i});
            index_data=time_markers{1,i};
            % detect outlier
            index_data_diff=diff(index_data(1,1:end));
            % determine missing timestep and fill missing index_data
            outlier=find(isoutlier(index_data_diff,'movmedian',movemedian_window));
            ref_period=movmedian(index_data_diff,movemedian_window);
            % % note that the missing time step is between index_data(outlier(k)) and index_data(outlier(k)+1)
            insert_all_index=[];
            for k=[1:1:size(outlier,2)]
                current_ref_period=ref_period(outlier(k));
                thispoint=index_data(outlier(k)); % the last point before missing index_data
                nextpoint=index_data(outlier(k)+1); % the first point after missing index_data
                gap=nextpoint-thispoint;
                insert_flag=1;
                insert_index=[];
                if(current_ref_period*(2-tolerance)>gap)
                    insert_flag=0; % the gap is too small, no need to insert
                end   
                if(insert_flag)
                    n=2;  % n represent the number of current_ref_period in gap roughly
                    while(1)
                        if( (current_ref_period*(n-tolerance)<=gap) & (current_ref_period*(n+tolerance)>=gap) )
                            break;
                        elseif(current_ref_period*(n+1-tolerance)>gap)
                            break;
                        end
                        n=n+1;
                    end            
                    for r=[1:1:n-1] % the number of inset point should be n-1
                        % note that we should fill index rather than orignal data
                        insert_index=[insert_index, round(thispoint+r*current_ref_period)];
                    end
                end
                insert_all_index=[insert_all_index, insert_index];      
            end
            % insert_all_indexs is used for following data filling
            insert_all_indexs{i,1}=insert_all_index;
            index_data=sort([index_data,insert_all_index]);
            index_data_temp=unique(index_data);
            assert(isequal(index_data_temp,index_data));
            time_markers{i}=index_data;
        end
        RpeakIndex_ECG=time_markers{1,1};
        footIndex_BP=time_markers{1,2};
        footIndex_PPG=time_markers{1,3};
        systolicIndex_BP=time_markers{1,4};
        systolicIndex_PPG=time_markers{1,5};
        notchIndex_BP=time_markers{1,6};
        notchIndex_PPG=time_markers{1,7};
        dicroticIndex_BP=time_markers{1,8};
        dicroticIndex_PPG=time_markers{1,9};

        % eliminate the incomplete first and last period
        % eliminate the incomplete first period
        % % set the ECG R peak to be the reference
        % % Each pulse should be ECG R peak, PPG(BP) foot, PPG(BP) systolic peak, PPG(BP) notch, PPG(BP) dicrotic peak in order
        RpeakIndex_ECG=RpeakIndex_ECG(1,2:end);
        while(footIndex_PPG(1,1)<RpeakIndex_ECG(1,1))
            footIndex_PPG=footIndex_PPG(1,2:end);
        end
        while(systolicIndex_PPG(1,1)<footIndex_PPG(1,1))
            systolicIndex_PPG=systolicIndex_PPG(1,2:end);
        end
        while(notchIndex_PPG(1,1)<systolicIndex_PPG(1,1))
            notchIndex_PPG=notchIndex_PPG(1,2:end);
        end
        while(dicroticIndex_PPG(1,1)<notchIndex_PPG(1,1))
            dicroticIndex_PPG=dicroticIndex_PPG(1,2:end);
        end
        % % % note that the comparison standard is little different
        [temp,posi]=min(abs(footIndex_BP-RpeakIndex_ECG(1,1)));
        footIndex_BP=footIndex_BP(1,posi:end);
        while(systolicIndex_BP(1,1)<footIndex_BP(1,1))
            systolicIndex_BP=systolicIndex_BP(1,2:end);
        end
        while(notchIndex_BP(1,1)<systolicIndex_BP(1,1))
            notchIndex_BP=notchIndex_BP(1,2:end);
        end
        while(dicroticIndex_BP(1,1)<notchIndex_BP(1,1))
            dicroticIndex_BP=dicroticIndex_BP(1,2:end);
        end

       
% % =====================================================================
%         % eliminate the redundant points in each period
        temp1=[RpeakIndex_ECG(1,1)];
        temp2=[];
        temp4=[];
        temp6=[];
        temp8=[];
        temp3=[];
        temp5=[];
        temp7=[];
        temp9=[];
        k=1;
        while(1) 
            temp0=footIndex_PPG(footIndex_PPG>(temp1(1,k)-10));
            if(size(temp0,2)==0)
                break;
            else
                temp3=[temp3,temp0(1,1)];
            end
            temp0=systolicIndex_PPG(systolicIndex_PPG>temp3(1,k));
            if(size(temp0,2)==0)
                break;
            else
                temp5=[temp5,temp0(1,1)];
            end
            temp0=notchIndex_PPG(notchIndex_PPG>temp5(1,k));
            if(size(temp0,2)==0)
                break;
            else
                temp7=[temp7,temp0(1,1)];
            end
            temp0=dicroticIndex_PPG(dicroticIndex_PPG>temp7(1,k));
            if(size(temp0,2)==0)
                break;
            else
                temp9=[temp9,temp0(1,1)];
            end     
             temp0=RpeakIndex_ECG(RpeakIndex_ECG>temp1(1,k));
           
            if(size(temp0,2)==0)
                break;
            else
                temp1=[temp1,temp0(1,1)];
            end
            k=k+1;
        end
        for(k=[1:1:size(temp1,2)]) % a little different, here we don't change temp1
           [temp,posi]=min(abs(footIndex_BP-temp1(1,k)));
            temp2=[temp2,footIndex_BP(posi)];
            temp0=systolicIndex_BP(systolicIndex_BP>temp2(1,k));
            if(size(temp0,2)==0)
                break;
            else
                temp4=[temp4,temp0(1,1)];
            end
            temp0=notchIndex_BP(notchIndex_BP>temp4(1,k));
            if(size(temp0,2)==0)
                break;
            else
                temp6=[temp6,temp0(1,1)];
            end
            temp0=dicroticIndex_BP(dicroticIndex_BP>temp6(1,k));
            if(size(temp0,2)==0)
                break;
            else
                temp8=[temp8,temp0(1,1)];
            end
        end
%% =======================================================================================
%        delete the last incomplete periofd
        
        len_index=min([size(temp1,2),size(temp2,2),size(temp3,2),size(temp4,2),size(temp5,2),size(temp6,2),size(temp7,2),size(temp8,2),size(temp9,2)]);
         RpeakIndex_ECG=temp1(1:1:len_index);
        footIndex_PPG=temp3(1:1:len_index);
        systolicIndex_PPG=temp5(1:1:len_index);
        notchIndex_PPG=temp7(1:1:len_index);
        dicroticIndex_PPG=temp9(1:1:len_index);
        footIndex_BP=temp2(1:1:len_index);
        systolicIndex_BP=temp4(1:1:len_index);
        notchIndex_BP=temp6(1:1:len_index);
        dicroticIndex_BP=temp8(1:1:len_index);
           
            if footIndex_PPG(1)==footIndex_PPG(2)
                footIndex_PPG(1)=[];
                systolicIndex_PPG(1)=[];
                notchIndex_PPG(1)=[];
                dicroticIndex_PPG(1)=[];
                footIndex_BP(1)=[];
                systolicIndex_BP(1)=[];
                notchIndex_BP(1)=[];
                dicroticIndex_BP(1)=[];
                RpeakIndex_ECG=RpeakIndex_ECG(1:end-1);
            end
        % calculate number of spoints of each signal, display
        statistic=[size(RpeakIndex_ECG,2),size(footIndex_BP,2),size(footIndex_PPG,2),size(systolicIndex_BP,2),size(systolicIndex_PPG,2),...
            size(notchIndex_BP,2), size(notchIndex_PPG,2),size(dicroticIndex_BP,2), size(dicroticIndex_PPG,2)];
%         if( size(find(statistic(statistic>=max(statistic))),2) <size(statistic,2))
%             disp('data point not in same number!!!!');
%             disp(p);
%             disp(q);
%         end
            if footIndex_PPG(1)==footIndex_PPG(2)
                footIndex_PPG(1)=[];
                systolicIndex_PPG(1)=[];
                notchIndex_PPG(1)=[];
                dicroticIndex_PPG(1)=[];
                RpeakIndex_ECG=RpeakIndex_ECG(1:end-1);
            end
%% =          
         [ footIndex_BP,  systolicIndex_BP] = finaldouble_check( BP, footIndex_BP,  systolicIndex_BP );
         [ footIndex_PPG,  systolicIndex_PPG] = finaldouble_check( PPG, footIndex_PPG,  systolicIndex_PPG );
         [ dicroticIndex_PPG,  notchIndex_PPG] = finaldouble_check2( PPG, dicroticIndex_PPG,  notchIndex_PPG );
         [ RpeakIndex_ECG ] = ECG_check( ECG, RpeakIndex_ECG );
           if max(systolicIndex_BP)>length(BP)
         systolicIndex_BP(len_index)=length(BP);
           end


       
        [feature_person,position_features]= feature_collect(BP,PPG,len_index,statistic,RpeakIndex_ECG,systolicIndex_BP,footIndex_BP,insert_all_indexs,systolicIndex_PPG,footIndex_PPG,dicroticIndex_PPG,notchIndex_PPG);
        
%         feature_person1=horzcat(PTTp,PTTf,RI,Systolic_timespan,Up_time,Systolic_volume,Diastolic_volume,HR,SBP,DBP,MBP);
%         position_features=horzcat(RpeakIndex_ECG',footIndex_PPG',systolicIndex_PPG',notchIndex_PPG',dicroticIndex_PPG');

        sample_num=floor((size(feature_person,1)-sample_beats)/shift_beats); % here one sample has 64 groups of features
        sample_order=0;
%         for(k=[1:1:sample_num])        
%             feature=feature_person(1+(k-1)*shift_beats:(k-1)*shift_beats+sample_beats,:);
%             sample_order=sample_order+1;
%             feature_mat=strcat(directory,subdir_storedata,'/',name_cell0{1,p},'/person_',num2str(q),'_sample_',num2str(sample_order),'_',name_cell0{1,p},'_feature.mat');
%             save(feature_mat,'feature');
%         end
        
        % the feature  should be clear!!!
        vars={'PTTp', 'PTTf','Up_time','Bf_time','Down_time','Fb_time','Bb_time',...
        'Cf_slope','Bc_slope','Cb_slope','Systolic_volume','Systolic_notch_volume',...
        'Notch_diastolic_volume','Diastolic_volume','Systolic_dicrotic_RI','Systolic_foot_RI',...
        'Systolic_notch_RI','Dicrotic_notch_RI','HR','SBP', 'DBP', 'MBP'};
        clear(vars{:})


end