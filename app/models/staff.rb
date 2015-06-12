class Staff < ActiveRecord::Base
  #acts_as_reportable
  before_save  :titleize_name

  def titleize_name
    self.name = name.titleize
  end
  
  has_many :vehicles, :dependent => :destroy
  accepts_nested_attributes_for :vehicles, :allow_destroy => true, :reject_if => lambda {|a| a[:cylinder_capacity].blank? }##|| a[:reg_no].blank?}
  validates_associated :vehicles
    
  has_attached_file :photo,
                    :url => "/assets/staffs/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/assets/staffs/:id/:style/:basename.:extension"#, :styles => {:thumb => "40x60"}
  #:styles => {:thumb => "100x100#" }
  
 # validates_attachment_presence :photo
  validates_attachment_size         :photo, :less_than => 500.kilobytes
  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png']
 #---------------Validations------------------------------------------------
  validates_numericality_of :icno#, :kwspcode
  validates_length_of       :icno, :is =>12
  validates_presence_of     :icno, :name, :coemail, :code, :appointdt #appointment date must exist be4 can apply leave
  validates_uniqueness_of   :icno, :fileno, :coemail, :code
  validates_format_of       :name, :with => /^[a-zA-Z'`\/\.\@\ ]+$/, :message => I18n.t('activerecord.errors.messages.illegal_char') #add allowed chars between bracket
  validates_presence_of     :cobirthdt, :addr, :poskod_id, :staffgrade_id, :statecd, :country_cd, :fileno
  #validates_length_of      :cooftelno, :is =>10
  #validates_length_of      :cooftelext, :is =>5
  validates_length_of       :addr, :within => 1..180,:too_long => "Address Too Long"
  validates_format_of       :coemail,
                               :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                               :message => I18n.t('activerecord.errors.messages.invalid')
 #-----------------------------------------------------------------------------------------------------------
  
  
#----------Link Foreign Key with other pages---------------------------------------------------

  has_many :documents,    :class_name => 'Documents', :foreign_key => 'stafffiled_id' 
  has_many :cc1s,         :class_name => 'Documents', :foreign_key => 'cc1staff_id' 
  has_many :books,        :foreign_key => 'receiver_id' 
  has_many :locations,    :class_name => 'Locations', :foreign_key => 'staffadmin_id'
  has_many :assigned,     :class_name => 'Assets', :foreign_key => 'assignedto_id'
  has_many :rxassets,     :class_name => 'Assets', :foreign_key => 'receiver_id'
  has_many :bulletins,    :foreign_key => 'postedby_id'
  has_many :sdiciplines,  :foreign_key => 'reportedby_id'
  has_many :strainings,   :foreign_key => 'staff_id'
  has_many :librarytransactions
  has_one  :position #has_many :positions #  #20Apr2013
  has_many :events,       :foreign_key => 'createdby'                                      #link to created by in events
  has_many :logins
  has_many :timetables
  has_one  :staff_shift
  # has_many :topics, :foreign_key => 'creator_id' 
  #has_many :curriculums, :foreign_key => 'staff_id'
  #has_many :txsuppliess, :foreign_key => 'staff_id'
  #has_many :bulletins, :foreign_key => 'staff_id'  seriously?!  theres no staff_id in this table!  
  # you also repeated this in line 66!!!!!   Now see the corresponding in bulletin.rb
  #has_many :assetloss, :foreign_key => 'staff_id'
  #has_many :evactivities, :foreign_key => 'staff_id'
 
  
  #-----------------belongs_to other page-----------------------------------------------------
  
  belongs_to :title, :class_name => 'Title', :foreign_key => 'titlecd_id'
  belongs_to :level,  :class_name => 'Qualification', :foreign_key => 'level_id'
  belongs_to :staffgrade, :class_name => 'Employgrade', :foreign_key => 'staffgrade_id'
  has_many   :ptdos #staff training
  has_many   :mycpds, :dependent => :destroy
  accepts_nested_attributes_for :mycpds, :allow_destroy => true #, :reject_if => lambda { |a| a[:cpd_year].blank? }
  validates_associated :mycpds
  #-------------display data for different table-----------------------------------------------
 
  #Link to model bulletin
  #has_many :bulletin, :class_name => 'bulletin', :foreign_key => 'postedby_id'  #posted by
  
  #Trainingrequest
  has_many :applicants, :class_name => 'Trainingrequest', :foreign_key => 'staff_id'
  has_many :approvers, :class_name => 'Trainingrequest', :foreign_key => 'approvedby_id'
  #has_many :trainingrequests
  
  #Link to model Staff Appraisal                                                      
  has_many :appraisals,     :class_name => 'StaffAppraisal', :foreign_key => 'staff_id', :dependent => :destroy
  has_many :eval1_officers, :class_name => 'StaffAppraisal', :foreign_key => 'eval1_by'
  has_many :eval2_officers, :class_name => 'StaffAppraisal', :foreign_key => 'eval2_by'
  
  
  #Link to model Asset Defect
  has_many :reporters, :class_name => 'AssetDefect', :foreign_key => 'reported_by'
  
  #Link to model Asset Disposal
  has_many :processors, :class_name => 'AssetDisposal', :foreign_key => 'checked_by'
  has_many :verifiers,  :class_name => 'AssetDisposal', :foreign_key => 'verified_by'
  has_many :revaluers,  :class_name => 'AssetDisposal', :foreign_key => 'revalued_by'
    
  #Link to model AssetTrack
  has_many :asset_loans
  has_many :owners, :class_name => 'AssetLoan', :foreign_key => 'loaned_by'
  has_many :hods,   :class_name => 'AssetLoan', :foreign_key => 'hod'
  #has_many :staffinassettrack, :class_name => 'assettrack', :foreign_key => 'staff_id'
  #has_many :isby,              :class_name => 'assettrack', :foreign_key => 'issuedby'
  #has_many :assettrackreturn,  :class_name => 'assettrack', :foreign_key => 'returnedto'  
  
  #
  has_and_belongs_to_many :messages
  has_many :from, :class_name => 'Staff', :foreign_key => 'from_id'
  
  #24Jan2015
  has_many :circulations
  has_many :documents, :through => :circulations
  #5APR2013
  #has_and_belongs_to_many :documents
  #has_many :from, :class_name => 'Staff', :foreign_key => 'from_id'
  
  #links to Model Cofile
  has_many :owners,    :class_name => 'Cofiles', :foreign_key => 'owner_id'
  has_many :borrowers, :class_name => 'Cofiles', :foreign_key => 'staffloan_id'
  
  #Link to Model travel_claim
  has_many :travel_claims, :dependent => :destroy
  has_many :approvers,           :class_name => 'TravelClaim',      :foreign_key => 'approved_by'
  has_many :checkers,            :class_name => 'TravelClaim',      :foreign_key => 'checked_by'
  
  #Link to Model Supplier
  has_many :issueds,      :class_name => 'StationeryUse',   :foreign_key => 'issuedby'
  has_many :receiveds,    :class_name => 'StatoneryUse',   :foreign_key => 'receivedby'
  
  #Link to Model Topic
  has_many :creator,    :class_name => 'Topic',    :foreign_key => 'creator_id'
  has_many :approver,   :class_name => 'Topic',    :foreign_key => 'approvedby_id'
  
  #Link to Model Training Report
  has_many :creator,  :class_name => 'Trainingreport',  :foreign_key => 'staff_id'
  has_many :tpa,      :class_name => 'Trainingreport',  :foreign_key => 'tpa_id'
  
  #link to model Examquestion
  has_many :approver,   :class_name => 'Examquestion',   :foreign_key => 'approver_id' #approver name
  has_many :creator,    :class_name => 'Examquestion',   :foreign_key => 'creator_id'  #creator name
  has_many :editor,     :class_name => 'Examquestion',   :foreign_key => 'editor_id'   #editor name
  
  #link to model Exams
  has_many :creators,          :class_name => 'Exam',   :foreign_key => 'created_by'
  
  
  
  
  #links to Model TravelRequest
  has_many :travelrequests,             :class_name => 'TravelRequest', :foreign_key => 'staff_id', :dependent => :destroy #staff name
  has_many :replacements,       :class_name => 'TravelRequest', :foreign_key => 'replaced_by' #replacement name
  has_many :headofdepts,        :class_name => 'TravelRequest', :foreign_key => 'hod_id' #hod
  
  #links to Model Attendances
  has_many :attendingstaffs,    :class_name => 'StaffAttendance', :foreign_key => 'thumb_id', :primary_key => 'thumb_id'#, :dependent => :destroy #attendance staff name
  has_many :approvers,          :class_name => 'StaffAttendance', :foreign_key => 'approved_by' # approver name
  
  #links to Model Assetloss
   has_many :handlers,      :class_name => 'AssetLoss',   :foreign_key => 'last_handled_by' 
   has_many :enforcers,     :class_name => 'AssetLoss',   :foreign_key => 'prev_action_enforced_by' 
   has_many :investigators, :class_name => 'AssetLoss',   :foreign_key => 'investigated_by' 
   has_many :sec_officers,  :class_name => 'AssetLoss',   :foreign_key => 'security_officer_id'
   has_many :hods,          :class_name => 'AssetLoss',   :foreign_key => 'security_officer_id'


   
  #links to Model Course
  has_many :admin,        :class_name => 'Course', :foreign_key => 'staff_id'
  
  #links to Model leaveforstaffs
   has_many :leave_applications, :class_name => 'Leaveforstaff', :foreign_key => 'staff_id', :dependent => :destroy
   has_many :replacements,       :class_name => 'Leaveforstaff', :foreign_key => 'replacement_id', :dependent => :nullify
   has_many :seconders,          :class_name => 'Leaveforstaff', :foreign_key => 'approval1_id', :dependent => :nullify
   has_many :approvers,          :class_name => 'Leaveforstaff', :foreign_key => 'approval2_id', :dependent => :nullify
  
  
  #links to Model Qualification
  #has_many :qualification, :class_name => 'Qualification', :foreign_key => 'level_id'
  
  #links to Model Trainneeds
   has_many :staff_that_need_training, :class_name => 'Trainneed', :foreign_key => 'staff_id'
   has_many :training_managers, :class_name => 'Trainneed', :foreign_key => 'confirmedby_id'
   
  #links to Model Weeklytimetables-20March2013
   has_many :prepared_weekly_schedules, :class_name => 'Weeklytimetable', :foreign_key => 'prepared_by', :dependent => :nullify
   has_many :endorsed_weekly_schedules, :class_name => 'Weeklytimetable', :foreign_key => 'endorsed_by', :dependent => :nullify
  #links to Model Weeklytimetables-21March2013
   has_many :weekly_schedule_details, :class_name => 'WeeklytimetableDetail', :foreign_key => 'lecturer_id', :dependent => :nullify
  #links to Model Topicdetail
   has_many :topic_details, :class_name => 'Topicdetail', :foreign_key => 'prepared_by', :dependent => :nullify
  #links to Model LessonPlan-26March2013
   has_many :lessonplan_lecturers, :class_name => 'LessonPlan', :foreign_key => 'lecturer' 
   has_many :lessonplan_creators, :class_name => 'LessonPlan', :foreign_key => 'prepared_by'
#-------------Empty Field for Foreign Key Link------------------------
  has_many :courses
  has_many :sdiciplines
  has_many :attendances
  has_many :leaveforstudents  #approval of student leave
#---------------------------------------------------------------------
     

    # def hod_with_name
    #   "#{formatted_mykad} #{name}"
    # end
#--------------------------------------------------------------------
  #has_many :travelrequests
#--------------------------------------------------------------------------
  
  has_many :student_counseling_sessions, :as => :created_by,  :foreign_key => 'created_by' 
  

  has_many :trainingnotes,    :class_name => 'Trainingnote'

#----------------------------code for repeating fields------------------------------------------  
 
  has_many :qualifications, :dependent => :destroy
  accepts_nested_attributes_for :qualifications, :allow_destroy => true, :reject_if => lambda { |a| a[:level_id].blank? }
  
  has_many :loans, :dependent => :destroy
  accepts_nested_attributes_for :loans, :allow_destroy => true,:reject_if => lambda { |a| a[:ltype].blank? }

  has_many :kins, :dependent => :destroy
  accepts_nested_attributes_for :kins, :allow_destroy => true, :reject_if => lambda { |a| a[:kintype_id].blank? }
  validates_associated :kins
  
  has_many :bankaccounts, :dependent => :destroy
  accepts_nested_attributes_for :bankaccounts,:allow_destroy => true, :reject_if => lambda { |a| a[:account_no].blank? }
  
 
     
     
     
#--------------------Declerations----------------------------------------------------
  def age
    Date.today.year - cobirthdt.year
  end
 
  def formatted_mykad
    "#{icno[0,6]}-#{icno[6,2]}-#{icno[-4,4]}"
  end
  
  def staff_name_then_mykad
    "#{name}  (#{formatted_mykad})"
  end
  
  def mykad_with_staff_name
    "#{formatted_mykad}  #{name}"
  end

  def position_with_name   #this currenlt works with staff leave
      "#{name}  (#{position.name})"
  end
  
  def staff_name_with_position
    "#{name}  (#{position_for_staff})"
  end
  
  def staff_name_with_position_grade_unit
      "#{name}  (#{position_for_staff}-#{grade_for_staff}-#{unit_for_staff})"
  end
  
  def position_for_staff
    if position.blank?
      "-"
    else
      position.name
    end
  end
  
  def position_code_for_staff
    if position.blank?
      "-"
    else
      position.code
    end
  end
  
  def unit_for_staff
    if position.blank?
      "-"
    else
      "#{position.try(:unit)}"
    end
  end
    
  def grade_for_staff
    if position.blank?
       "-"
    else
       "#{position.staffgrade.try(:name)}"
    end
  end
    
  def my_bank
    sid = id
    b = Bankaccount.find(:all, :select => "bank_id", :conditions => {:staff_id => sid}).map(&:bank_id)
    if b == nil
      "No Account Registered"
    else
      id = b[0]
      Bank.find(:all, :select => "long_name", :conditions => {:id => id}).map(&:long_name).to_s
    end
  end

  
  def render_reports_to
      "#{position.try(:parent).try(:name)} - #{position.try(:parent).try(:staff).try(:name)}"
  end
  
  def render_unit
    if position.blank? 
      "Staff not exist in Task & Responsibilities"
    #elsif position.parent.blank?
     #   "-"
    elsif position.is_root?
        "Pengarah"
    elsif position.parent.is_root?
      if position.unit.blank?
        "#{position.name}"                  #display position name instead - must be somebody!
      else
        "#{position.unit}"                  #   "#{position.unit} - 3"
      end
    elsif position.parent.staff.blank?      #no parent
      #  "#{position.parent.unit} -1 "
      if position.parent.unit.blank?
        "#{position.unit}"                  #  "#{position.unit} - 1a"
      else  
        "#{position.parent.unit}"           #  "#{position.parent.unit} - 1b"
      end
    else                                    #got parent
      if position.parent.unit.blank?
        "#{position.unit}"                  #  "#{position.unit} - 2a"
      else  
        "#{position.parent.unit}"           #  "#{position.parent.unit} - 2b"
      end
    end
  end
  
  def staff_positiontemp
    sid = staff.id
    spo = Position.find(:all, :select => "name", :conditions => {:staff_id => sid}).map(&:name)
    if spo == nil
      "NA"
    else 
      @staff.position.name
    end 
  end
  
  def staff_position
    sid = staff.id
    Position.find(:all, :select => "name", :conditions => {:staff_id => sid}).map(&:name)
  end
 
  def shift_for_staff
    ssft = StaffShift.find(:first, :conditions=> ['id=?',staff_shift_id])
    if ssft == nil
      "-"
    else
      ssft.start_end
    end
  end

  def icno_with_staff_name
    "#{icno}  #{name}"
  end
  
  def bil
    v=1
  end
  
  #1July2013
  def staff_thumb
    "#{name}  (thumb id : #{thumb_id})"
  end  
  
  
#------------------Coded Lists----------------------------------------- 
  MARITAL_STATUS = [
       #  Displayed       stored in db
       [ "Tidak Pernah Berkahwin",1 ],
       [ "Berkahwin",2 ],
       [ "Balu", 3 ],
       [ "Duda", 4],
       [ "Bercerai", 5 ],
       [ "Berpisah", 6 ],
       [ "Tiada Maklumat", 9 ]
  ]
     
  BLOOD_TYPE = [
      #  Displayed       stored in db
      [ "O-",          "1" ],
      [ "O+",    "2" ],
      [ "A-", "3" ],
      [ "A+", "4" ],
      [ "B-", "5" ],
      [ "B+", "6" ],
      [ "AB-", "7" ],
      [ "AB+", "8" ]
      
  ]
         
  STATECD = [
      #  Displayed       stored in db
      [ "Johor",         1 ],
      [ "Kedah",    2 ],
      [ "Kelantan", 3 ],
      [ "Melaka", 4],
      [ "Negeri Sembilan", 5 ],
      [ "Pahang", 6 ],
      [ "Pulau Pinang", 7 ],
      [ "Perak", 8 ], 
      [ "Perlis", 9 ],
      [ "Selangor", 10 ], 
      [ "Terengganu", 11 ], 
      [ "Sabah", 12 ], 
      [ "Sarawak", 13 ],
      [ "Wilayah Persekutuan Kuala Lumpur", 14 ],
      [ "Wilayah Persekutuan Labuan", 15 ],
      [ "Wilayah Persekutuan Putrajaya", 16 ],
      [ "Luar Negara", 98 ],       
  ]
  
  NATIONALITY = [
       #  Displayed       stored in db
       [ "Warganegara",1],
       [ "Bukan Warganegara",2],
       [ "Penduduk Tetap", 3],
  ]
  
  STATUS = [
        #  Displayed       stored in db
        [ "Tetap",1 ],
        [ "Sementara",2 ],
        [ "Sambilan",3 ]
  ]
  
  APPOINTMENT = [
       #  Displayed       stored in db
       [ "Sandangan Tetap","1" ],
       [ "Sandangan Sementara","2" ],
       [ "Memangku Dengan Tujuan Naik Pangkat","3" ],
       [ "Memangku Bukan Dengan Tujuan Naik Pangkat","4" ],
       [ "Tanggung Kerja","5" ],
       [ "Sandangan Khas Untuk Penyandang","6" ],
       [ "Sandangan Sambilan","7" ],
       [ "Sandangan Khidmat Singkat","8" ]


  ]
  
  APPOINTED = [
       #  Displayed       stored in db
       [ "Kementerian Kesihatan Malaysia","kkm" ],
       [ "Suruhanjaya Perkhidmatan Awam","spa" ],
       [ "Jabatan Perkhidmatan Awam","jpa" ]
       
  ]
  
  HOS = [
       #  Displayed       stored in db
       [ "Suruhanjaya Perkhidmatan Awam","spa" ],
       [ "Kementerian Kesihatan Malaysia","kkm" ],
       [ "Jabatan Perkhidmatan Awam","jpa" ],
       [ "Jabatan Perpustakaan Negara","jpn" ]
       
  ]
  
  TOS = [
       #  Displayed       stored in db
       [ "Persekutuan","p" ],
       [ "Negeri","n" ]   
  ]
  
  PENSION = [
       #  Displayed       stored in db
       [ "Berpencen", "1"],
       [ "Pilihan KWSP", "2"],
       [ "Belum Memilih", "3"],
       [ "Tidak Layak Memilih","4"]

  ]
  
  UNIFORM = [
        #  Displayed       stored in db
        [ "Dibekalkan/Tidak dibekalkan", "1" ],
        [ "Tarikh Akhir di beri", "2" ],
        [ "Elaun Pakaian Panas/Pakaian Istiadat", "3" ]


  ]
  
  RACE = [
        #  Displayed       stored in db
        [ "Malay",1 ],
        [ "Chinese",2 ],
        [ "India",3 ],
        [ "Others",4 ],
  ]
  
  RELIGION = [
        #  Displayed       stored in db
        [ "Islam",1],
        [ "Buddha",2 ],
        [ "Hindu",3 ],
        [ "Others",4 ],
  ]
  
  GENDER = [
        #  Displayed       stored in db
        [ "Male","1"],
        [ "Female","2"]
  ]
 
#----------------Staff Attendance-colour status------
  def render_colour_status
    (StaffAttendance::ATT_STATUS.find_all{|disp, value| value == att_colour.to_i}).map {|disp, value| disp}
  end

#---------------Search--------------------------------------------------------------------------------
                        
  def self.search(search)
     if search
      @staff = Staff.find(:all, :conditions => ["icno LIKE ? or name ILIKE ?", "%#{search}%","%#{search}%"], :order => :icno)
     else
      @staff = Staff.find(:all,  :order => :icno)
     end
  end
  
  def jantina 
    if gender==2
       "P"
    elsif gender==1
      "L"
    end
  end
  
  #giving full access to Pengajar Subjek Asas on Weeklytimetable (of ALL programmes) - refer authorization rules under LECTURER role
  #related to this comment (1) 2.1.2 Student Attendance, item no.3, (2) 2.3.1 Scheduling, comment no.11 (part B)
  def commonsubject_lecturer_programmeid_list
    unit = Login.current_login.staff.position.unit
    current_lecturer = Login.current_login.staff.id
    common_subjects = ["Sains Perubatan Asas", "Anatomi & Fisiologi", "Sains Tingkahlaku", "Komunikasi & Sains Pengurusan"]
    is_common_lecturer = Position.find(:all, :conditions=>['unit IN(?) and staff_id=?', common_subjects, current_lecturer])
    if is_common_lecturer.count>0
      return Programme.roots.map(&:id)      #shall return this [1, 3, 4, 5, 14, 13, 2, 67, 12, 6, 7, 9, 11, 10, 185, 1697, 1707, 1709, 8]
    else
      return []
    end
  end
  
  def under_my_supervision
    unit= Login.current_login.staff.position.unit
    if Programme.roots.map(&:name).include?(unit) || ["Pengkhususan", "Pos Basik", "Diploma Lanjutan"].include?(unit)
      if Programme.roots.map(&:name).include?(unit)
        course_id = Programme.find(:first, :conditions =>['name=? and ancestry_depth=?', unit,0]).id
      elsif ["Pengkhususan", "Pos Basik", "Diploma Lanjutan"].include?(unit)
        main_task_first = Login.current_login.staff.position.tasks_main
         prog_name_full = main_task_first[/Diploma Lanjutan \D{1,}/] if ["Diploma Lanjutan"].include?(unit)
         prog_name_full = main_task_first[/Pos Basik \d{1,}/] if ["Pos Basik"].include?(unit)
         prog_name_full = main_task_first[/Pengkhususan \d{1,}/] if ["Pengkhususan"].include?(unit)
#         prog_name_full = main_task_first[/"#{unit}" \D{1,}/]
        prog_name = prog_name_full.split(" ")[prog_name_full.split(" ").size-1]
        course_id = Programme.find(:first, :conditions =>['name ILIKE(?) and course_type=?', "%#{prog_name}%", unit]).id
      end 
      main_task = Login.current_login.staff.position.tasks_main
      coordinator=main_task[/Penyelaras Kumpulan \d{1,}/]   
      if coordinator
        intake_group=coordinator.split(" ")[2]   #should match 'descripton' field in Intakes table
        intake = Intake.find(:first, :conditions=>['programme_id=? and description=?', course_id, intake_group]).monthyear_intake
        if intake
          @supervised_student = Student.find(:all, :conditions=>['intake=? and course_id=?', intake, course_id]).map(&:id)
        end
      end
    
      @supervised_student=[] if !@supervised_student
      sib_lect_coordinates_groups=[]
      if Programme.roots.map(&:name).include?(unit)
        sib_lect_maintask= Position.find(:all, :conditions=>['unit=? and staff_id!=?', unit, Login.current_login.staff_id]).map(&:tasks_main)
        sib_lect_maintask.each do |y|
          coordinator2 =  y[/Penyelaras Kumpulan \d{1,}/]
          if coordinator2
            sib_lect_coordinates_groups << coordinator2.split(" ")[2]     #collect group with coordinator
          end
        end
      elsif ["Pengkhususan", "Pos Basik", "Diploma Lanjutan"].include?(unit)
        sib_lect_maintask_all_posbasik= Position.find(:all, :conditions=>['unit=? and staff_id!=?', unit, Login.current_login.staff_id]).map(&:tasks_main)
        sib_lect_maintask_all_posbasik.each do |x|
          coordinator2 =  x[/Penyelaras Kumpulan \d{1,}/]
          prog_name_full2 = main_task_first[/Diploma Lanjutan \D{1,}/] if ["Diploma Lanjutan"].include?(unit)
          prog_name_full2 = main_task_first[/Pos Basik \d{1,}/] if ["Pos Basik"].include?(unit)
          prog_name_full2 = main_task_first[/Pengkhususan \d{1,}/] if ["Pengkhususan"].include?(unit)
          prog_name2 =prog_name_full2.split(" ")[prog_name_full2.split(" ").size-1]
          if coordinator2 && prog_name==prog_name2
            sib_lect_coordinates_groups << coordinator2.split(" ")[2]     #collect group with coordinator
          end
        end
      end
      
      #Either I'm a coordinator (or not) of any student group/intake/batch, is there any group/intake/batch w/o coordinator that requires me to become ONE OF authorising programme lecturer (to approve student leave applications)
      #limit checking on existing leaveforstudent records 
    
      leave_applicant_ids = Leaveforstudent.all.map(&:student_id) #ALL student applying leave
      applicant_of_current_prog = Student.find(:all, :conditions=>['id IN(?) and course_id=?', leave_applicant_ids, course_id])#.map(&:id)
      #intake_for_applicant_current_prog = Student.find(:all, :conditions=>['id IN (?)', applicant_of_current_prog]).map(&intake)
      #intake_for_applicant_current_prog = Student.find(:all, :conditions=>['id IN(?) and course_id=?', leave_applicant_ids, course_id]).map(&:intake)
      applicant_of_current_prog.group_by{|x|x.intake}.each do |intatake, applicants|
        intake2 = Intake.find(:first, :conditions=>['programme_id=? and monthyear_intake=?', course_id, intatake.beginning_of_month])
        if intake2
	  intake2_group = intake2.description
          w_coordinator=sib_lect_coordinates_groups.include?(intake2_group)
	  @supervised_student+= applicants if !w_coordinator
        else
	  #this student group definitely got no coordinator as their intake not even exist in Intakes table
	  #add these applicants to supervised_student array! note 'applicants' is an array
	  @supervised_student+= applicants 
        end
      end 
      return @supervised_student
    else
      return []
    end
  end
  
#   def unit_members
#     exist_unit_of_staff_in_position = Position.find(:all, :conditions =>['unit is not null and staff_id is not null']).map(&:staff_id).uniq
#     if exist_unit_of_staff_in_position.include?(Login.current_login.staff_id)
#       current_unit = Position.find_by_staff_id(Login.current_login.staff_id).unit    
#       unit_members = Position.find(:all, :conditions=>['unit=?', current_unit]).map(&:staff_id).uniq-[nil]
#     else
#       unit_members = []#Position.find(:all, :conditions=>['unit=?', 'Teknologi Maklumat']).map(&:staff_id).uniq-[nil]
#     end
#     unit_members    #collection of staff_id (member of a unit/dept)
#   end
  
  def unit_members
    #Academicians & Mgmt staff : "Teknologi Maklumat", "Perpustakaan", "Kewangan & Akaun", "Sumber Manusia","logistik", "perkhidmatan" ETC.. - by default staff with the same unit in Position will become unit members, whereby Ketua Unit='unit_leader' role & Ketua Program='programme_manager' role.
    #Exceptional for - "Kejuruteraan", "Pentadbiran Am", "Perhotelan", "Aset & Stor" (subunit of Pentadbiran), Ketua Unit='unit_leader' with unit in Position="Pentadbiran", Note: whoever within these unit if wrongly assigned as 'unit_leader' will also hv access for all ptdos on these unit staff
    
    exist_unit_of_staff_in_position = Position.find(:all, :conditions =>['unit is not null and staff_id is not null']).map(&:staff_id).uniq
    if exist_unit_of_staff_in_position.include?(Login.current_login.staff_id)
      current_unit = Position.find_by_staff_id(Login.current_login.staff_id).unit
      
      #replace current_unit value if academician also a Unit Leader
      current_roles=Login.current_login.roles.map(&:name)
      current_unit=unit_lead_by_academician if current_roles.include?("Unit Leader") && Programme.roots.map(&:name).include?(current_unit)
      
      if current_unit=="Pentadbiran"
        unit_members = Position.find(:all, :conditions=>['unit=? OR unit=? OR unit=? OR unit=?', "Kejuruteraan", "Pentadbiran Am", "Perhotelan", "Aset & Stor"]).map(&:staff_id).uniq-[nil]+Position.find(:all, :conditions=>['unit=?', current_unit]).map(&:staff_id).uniq-[nil]
      elsif ["Teknologi Maklumat", "Pusat Sumber", "Kewangan & Akaun", "Sumber Manusia"].include?(current_unit) || Programme.roots.map(&:name).include?(current_unit)
        unit_members = Position.find(:all, :conditions=>['unit=?', current_unit]).map(&:staff_id).uniq-[nil]
      else #logistik & perkhidmatan inc. "Unit Perkhidmatan diswastakan / Logistik"
        unit_members = Position.find(:all, :conditions=>['unit ILIKE(?)', "%#{current_unit}%"]).map(&:staff_id).uniq-[nil] 
      end
    else
      unit_members = []#Position.find(:all, :conditions=>['unit=?', 'Teknologi Maklumat']).map(&:staff_id).uniq-[nil]
    end
    unit_members    #collection of staff_id (member of a unit/dept)
  end

  #call this method if academician also lead a mgmt unit
  def unit_lead_by_academician
    main_tasks=Login.current_login.staff.position.tasks_main
    if main_tasks.include?("Ketua Unit")   
      mgmt_unit=main_tasks.scan(/Ketua Unit(.*),/)[0][0].strip
    else
      mgmt_unit=""
    end
    mgmt_unit
  end
  
end
 
                      
 