%% 1. โหลดข้อมูล
clc; clear;
filename = "C:\Users\nitic\Documents\GitHub\FRA271-LAB2-B02-24-41-44\DC Motor and Stepper\DC_lab2\Wnl_Freq20000_2.mat";

if exist(filename, 'file')
    load(filename);
else
    error('ไม่พบไฟล์ %s', filename);
end

%% 2. ดึงข้อมูลและแก้ Format (Fix Error)
if exist('data', 'var')
    try
        % ดึงสัญญาณ Raw_W
        sig = data.getElement('Raw_W');
        
        % ดึงค่า Time และ Data
        t_raw = sig.Values.Time;
        v_raw = sig.Values.Data;
        
        % --- [จุดแก้ Error] แปลง Format ให้ Simulink ยอมรับ ---
        % 1. บังคับเป็นแนวตั้ง (Column Vector)
        t_sim = t_raw(:);
        v_sim = v_raw(:);
        
        % 2. บังคับเป็น Double Precision (Simulink บังคับว่า Time ต้องเป็น double)
        t_sim = double(t_sim);
        v_sim = double(v_sim); % แปลงค่าข้อมูลเป็น double ด้วยเพื่อความชัวร์
        
        % 3. บังคับเป็น Real Number (ตัดส่วนจินตภาพทิ้ง ถ้ามี)
        t_sim = real(t_sim);
        v_sim = real(v_sim);

        % 4. กำจัดค่าซ้ำหรือย้อนกลับ (Time ต้องเดินหน้าเท่านั้น)
        % บางครั้ง Error นี้เกิดจากเวลาที่ไม่เรียงกัน
        [t_sim, unique_idx] = unique(t_sim);
        v_sim = v_sim(unique_idx);

        % 5. สร้างตัวแปร timeseries
        % ตั้งชื่อตัวแปรตามที่คุณจะใช้ใน From Workspace Block
        my_signal = timeseries(v_sim, t_sim);
        
        % สร้างตัวแปรสำรองสำหรับตรวจสอบ (ตามโจทย์เก่า)
        Raw_W_Data = [t_sim, v_sim];

        fprintf('===========================================\n');
        fprintf('แก้ไข Format เรียบร้อย!\n');
        fprintf('สร้างตัวแปร "my_signal" สำหรับใส่ใน From Workspace แล้ว\n');
        fprintf('จำนวนข้อมูล: %d จุด\n', length(t_sim));
        fprintf('===========================================\n');
        
    catch ME
        warning('Error: %s', ME.message);
    end
else
    error('ไม่พบตัวแปร "data"');
end