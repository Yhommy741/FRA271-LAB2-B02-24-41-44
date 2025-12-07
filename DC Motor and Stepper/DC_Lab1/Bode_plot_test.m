%% =========================================================================
%  Bode_plot_test.m - Script for Loading, Cleaning, and Formatting Simulink Data
%  =========================================================================

%% 1. โหลดข้อมูล (Load Data)
% -------------------------------------------------------------------------
clc; clear;

% ตรวจสอบและแก้ไข Path ของไฟล์ตามเครื่องของคุณ
filename = "C:\Users\Yhommy\OneDrive\Documents\GitHub\FRA271-LAB2-B02-24-41-44\DC Motor and Stepper\DC_lab2\Wnl_Freq2000_2.mat"; 

if exist(filename, 'file')
    load(filename);
    fprintf('✅ โหลดไฟล์สำเร็จ: %s\n', filename);
else
    % ใช้ error เพื่อหยุดการทำงานหากไม่พบไฟล์
    error('❌ ไม่พบไฟล์ %s กรุณาตรวจสอบ Path', filename); 
end

---

%% 2. ดึงข้อมูลและแก้ Format (Extract Data and Fix Format)
% -------------------------------------------------------------------------
if exist('data', 'var')
    try
        % **แก้ไข Error 1:** เปลี่ยน 'Raw_W' เป็น 'W' ตามที่พบใน Dataset
        sig = data.getElement('W');
        
        if isempty(sig)
            error('Element "W" ถูกโหลดแต่ไม่มีข้อมูลอยู่ภายใน');
        end
        
        % ดึงค่า Time และ Data
        t_raw = sig.Values.Time;
        v_raw = sig.Values.Data;
        
        % --- การแปลง Format (Simulink Timeseries Requirements) ---
        
        % 1. บังคับเป็นแนวตั้ง (Column Vector)
        t_sim = t_raw(:);
        v_sim = v_raw(:);
        
        % 2. บังคับเป็น Double Precision (Simulink ต้องการ Time เป็น double)
        t_sim = double(t_sim);
        v_sim = double(v_sim); 
        
        % 3. บังคับเป็น Real Number (ตัดส่วนจินตภาพทิ้ง ถ้ามี)
        t_sim = real(t_sim);
        v_sim = real(v_sim);
        
        % 4. กำจัดค่าซ้ำหรือย้อนกลับ (Time ต้องเดินหน้าเท่านั้น)
        [t_sim, unique_idx] = unique(t_sim, 'stable');
        v_sim = v_sim(unique_idx);
        
        % 5. สร้างตัวแปร timeseries
        % ตัวแปรนี้ ('my_signal') คือตัวแปรที่คุณต้องใส่ใน From Workspace Block
        my_signal = timeseries(v_sim, t_sim);
        
        % สร้างตัวแปรสำรองสำหรับตรวจสอบ (ถ้าจำเป็นต้องใช้ Matrix 2 คอลัมน์)
        Raw_W_Data = [t_sim, v_sim]; 
        
        fprintf('===========================================\n');
        fprintf('✅ การแก้ไข Format สำเร็จ!\n');
        fprintf('สร้างตัวแปร **"my_signal"** สำหรับใช้ใน From Workspace Block แล้ว\n');
        fprintf('จำนวนข้อมูลที่ใช้ได้: **%d จุด**\n', length(t_sim));
        fprintf('===========================================\n');
        
    catch ME
        % แสดงรายละเอียด Error หากมีปัญหาในการเข้าถึงข้อมูล
        warning('❌ Error ในการประมวลผลข้อมูล: %s', ME.message);
    end
else
    error('❌ ไม่พบตัวแปร "data" หลังการโหลดไฟล์. ไฟล์ .mat อาจไม่มีตัวแปรชื่อนี้');
end