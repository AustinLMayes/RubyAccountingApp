bal_def = $stratus['balance']
raise "No balance data defined" if bal_def.blank?
$CUR_BAL = {
  date: Date.strptime(bal_def['date'], "%m/%d/%Y"),
  bal: (bal_def['balance'].to_f * 100).to_i
}
