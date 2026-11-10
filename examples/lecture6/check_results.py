import json, math
from pathlib import Path
import ROOT
ROOT.gROOT.SetBatch(True)
base=Path(__file__).resolve().parent
c=json.loads((base/'competition.json').read_text())
t=json.loads((base/'transport.json').read_text())
d=ROOT.RDataFrame('tree',str(base/'competition.root'))
alln=d.Count();m1=d.Mean('L1');m2=d.Mean('L2');mm=d.Mean('Lstep')
a=d.Filter('flag==0');b=d.Filter('flag==1')
an=a.Count();bn=b.Count();am=a.Mean('Lstep');bm=b.Mean('Lstep')
assert alln.GetValue()==c['n']==1000000
for val,key in [(m1,'mean_r1'),(m2,'mean_r2'),(mm,'mean_min'),(am,'mean_step_given_flag0'),(bm,'mean_step_given_flag1')]:
    assert math.isclose(val.GetValue(),c[key],rel_tol=1e-11),key
assert an.GetValue()==c['count_flag0'] and bn.GetValue()==c['count_flag1']
assert d.GetNRuns()==1
q=ROOT.RDataFrame('particles',str(base/'transport.root'))
num=q.Count();total=q.Mean('total');last=q.Mean('last');ns=q.Mean('nscatter');disp=q.Mean('displacement')
bad=q.Filter('total + 1e-10 < displacement || total < last || nscatter<0').Count()
assert num.GetValue()==t['n']==200000 and bad.GetValue()==0
for val,key in [(total,'mean_total_path'),(last,'mean_annihilation_step'),(ns,'mean_number_scatterings'),(disp,'mean_displacement')]:
    assert math.isclose(val.GetValue(),t[key],rel_tol=1e-11),key
assert math.isclose(t['mean_total_path'],t['mean_annihilation_step']+t['mean_number_scatterings']*t['mean_scattering_step'],rel_tol=1e-11)
lam=10/7
report={
 'competition_root_entries':alln.GetValue(),
 'transport_root_entries':num.GetValue(),
 'competition_min_mean_z':(c['mean_min']-lam)/(lam/math.sqrt(c['n'])),
 'flag0_fraction_z':(c['fraction_flag0']-5/7)/math.sqrt((5/7)*(2/7)/c['n']),
 'transport_total_mean_z':(t['mean_total_path']-5)/(5/math.sqrt(t['n'])),
 'transport_nscatter_mean_z':(t['mean_number_scatterings']-2.5)/math.sqrt(8.75/t['n']),
 'variance_weighting':'scattering step mean pools all realized scattering steps; one final annihilation step and one total length per particle',
 'identity_total_equals_last_plus_scatter_sum':True,
 'all_displacements_no_larger_than_path':True,
 'root_version':str(ROOT.gROOT.GetVersion())
}
assert all(abs(report[k])<3 for k in ['competition_min_mean_z','flag0_fraction_z','transport_total_mean_z','transport_nscatter_mean_z'])
(base/'verification.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
