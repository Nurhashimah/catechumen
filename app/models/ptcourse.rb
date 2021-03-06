class Ptcourse < ActiveRecord::Base
  belongs_to :provider, :class_name => 'AddressBook', :foreign_key => 'provider_id'
  has_many :ptschedules, :dependent => :destroy
  
  validates_presence_of :name, :provider
  validates_presence_of :level, :if => :trainingclass?
  
  def trainingclass?
    training_classification == 1
  end
  
  def rendered_programme_classification
    (Ptcourse::PROGRAMME_CLASSIFICATION.find_all{|disp, value| value == training_classification}).map {|disp, value| disp} 
  end
  
  def rendered_level
    (Ptcourse::LEVEL.find_all{|disp, value| value == level}).map {|disp, value| disp} 
  end
  
  def rendered_course_type
    (Ptcourse::COURSE_TYPE.find_all{|disp, value| value == course_type }).map {|disp, value| disp}
  end
  
  def rendered_course_duration
    (Ptcourse::DUR_TYPE.find_all{|disp, value| value == duration_type }).map {|disp, value| disp}
  end
  
  ##points required - hardcode here - pending - need advise
#   def course_type_points
#     if course_type == 5
#       points = 1
#     elsif course_type ==10
#       points = 2
#     elsif course_type ==15
#       points = 3
#     elsif course_type ==20
#       points = 4
#     elsif course_type ==25
#       points = 5
#     elsif course_type ==30
#       points = 6
#     elsif course_type ==35
#       points = 7
#     elsif course_type ==36
#       points = 8
#     elsif course_type ==37  
#       points = 9
#     elsif course_type ==38
#       points = 10
#     elsif course_type ==39
#       points = 11
#     end
#   end
  
#   COURSE_TYPE = [
#        #  Displayed       stored in db
#        [ I18n.t("ptcourse.in_house"),              5 ],
#        [ I18n.t("ptcourse.external_short_course"),10 ],
#        [ I18n.t("ptcourse.seminar"), "Seminar",              15 ],
#        [ I18n.t("ptcourse.certificate"),          20 ],
#        [ I18n.t("ptcourse.diploma_others") ,       25 ],
#        [ I18n.t("ptcourse.conference"),         30],
#        [ I18n.t("ptcourse.convention"),         35],
#        [ I18n.t("ptcourse.scientific_meeting"),         36],
#        [ I18n.t("ptcourse.scientific_congress"),         37],
#        [ I18n.t("ptcourse.scientific_conference"),         38],
#        [ I18n.t("ptcourse.workshop"),         39]
#   ]
#   
  #   [ I18n.t("ptcourse.course"),         40]
  PROGRAMME_CLASSIFICATION2 = [
       #  Displayed       stored in db
       ["Latihan", 1],
       ["Sesi Pembelajaran (Bersemuka)", 2],
       ["Sesi Pembelajaran (Tidak Bersemuka)", 3],
       ["Pembelajaran Kendiri", 4]
  ]
  
  PROGRAMME_CLASSIFICATION = [
       #  Displayed       stored in db
       [ I18n.t("ptcourse.training"), 1],
       [ I18n.t("ptcourse.confront"), 2],
       [ I18n.t("ptcourse.non_confront"), 3],
       [ I18n.t("ptcourse.self_training"), 4]
  ]
  
  LEVEL = [
       #  Displayed       stored in db
       [ I18n.t("ptcourse.domestic"), 1],
       [ I18n.t("ptcourse.overseas"), 2]
  ]
  
  COURSE_TYPE = [
       #  Displayed       stored in db
       [ I18n.t("ptcourse.course"), 1],
       [ I18n.t("ptcourse.seminar"), 2],
       [ I18n.t("ptcourse.convention"), 3],
       [ I18n.t("ptcourse.workshop"), 4],
       [ I18n.t("ptcourse.forum"), 5],
       [ I18n.t("ptcourse.symposium"), 6],
       [ I18n.t("ptcourse.learning_session"), 7],
       [ I18n.t("ptcourse.monthly_assembly"), 8],
       [ I18n.t("ptcourse.special_talk"), 9],
       [ I18n.t("ptcourse.celebration"), 10],
       [ I18n.t("ptcourse.presentation"), 11],
       [ I18n.t("ptcourse.speaker"), 12],
       [ I18n.t("ptcourse.job_visit"), 13],
       [ I18n.t("ptcourse.on_job_training"), 14],
       [ I18n.t("ptcourse.attachment_training"), 15],
       [ I18n.t("ptcourse.simulation"), 16],
       [ I18n.t("ptcourse.others"), 17],
       [ I18n.t("ptcourse.epsa_portal"), 18],  
       [ I18n.t("ptcourse.e_learning_portal"), 19],  
       [ I18n.t("ptcourse.hr_knowledge_repo"), 20],  
       [ I18n.t("ptcourse.book_reading"), 21],  
       [ I18n.t("ptcourse.jurnal_reading"), 22],  
  ]
  
  DUR_TYPE = [
       #  Displayed       stored in db
       [ I18n.t("time.hours"), 0],
       [ I18n.t("time.days"),  1 ],
       [ I18n.t("time.months"),2 ],
       [ I18n.t("time.years"), 3 ],
  ]
  
  def self.search(search)
    if search
      searched_provider_ids=AddressBook.find(:all, :conditions =>['name ILIKE (?)', "%#{search}%"]).map(&:id)
      ptcourses=Ptcourse.find(:all, :conditions =>['name ILIKE (?) or provider_id IN(?)', "%#{search}%", searched_provider_ids])
    else
      ptcourses=Ptcourse.find(:all, :order => "name ASC")
    end 
    ptcourses
  end
  
  ##-individual duration IN STRING of a ptcourse-start : usage (ptschedules/index.html.erb)
  def course_total_days
    if duration_type == 0
      total_days = (duration / 6).to_f
    elsif duration_type == 1
      total_days = duration*1
    elsif duration_type == 2
      total_days = duration*30
    elsif duration_type == 3
      total_days = duration*365
    end
    days_count = total_days * 6 / 6
    bal_hours = total_days * 6 % 6
    if bal_hours > 0
      if days_count.to_i > 0
        total_days_instring=days_count.to_i.to_s+" "+I18n.t('time.days')+" "+bal_hours.to_i.to_s+" "+I18n.t('time.hours')
      else
        total_days_instring=bal_hours.to_i.to_s+" "+I18n.t('time.hours')
      end
    else
      total_days_instring=days_count.to_i.to_s+" "+I18n.t('time.days') if days_count.to_i > 0
      total_days_instring=I18n.t('ptdos.nil') if days_count.to_i ==0
    end
    total_days_instring
  end
  ##-individual duration IN STRING of a ptcourse-end
  
end
