const sb=supabase.createClient('https://zcwyyifwjtyreevcbvwz.supabase.co','sb_publishable_GkicTQkKeMzI537TMyux9A_6gU2xy5C');
const $=id=>document.getElementById(id);
let users=[];
function view(name){for(const id of ['login','denied','dashboard'])$(id).classList.toggle('hidden',id!==name)}
async function init(){
 const {data:{session}}=await sb.auth.getSession();
 if(!session){window.location.replace('./');return}
 const {data,error}=await sb.rpc('is_csp_super_admin');
 if(error||data!==true){window.location.replace('./');return}
 view('dashboard');await refresh();
}
async function refresh(){
 const {data,error}=await sb.rpc('csp_admin_users');
 if(error){$('message').textContent='Cannot load users: '+error.message+'. Run SQL migration 12 in Supabase.';return}
 users=data||[];$('message').textContent='';
 $('total').textContent='Total: '+users.length;
 $('pending').textContent='Pending: '+users.filter(x=>x.status==='pending').length;
 $('active').textContent='Active: '+users.filter(x=>x.status==='active').length;
 const current=$('country').value;
 $('country').replaceChildren(new Option('All countries',''));
 for(const c of [...new Set(users.map(x=>x.country).filter(Boolean))].sort())$('country').add(new Option(c,c));
 $('country').value=current;render();
}
function render(){
 const query=$('search').value.toLowerCase(),status=$('status').value,country=$('country').value;
 const selected=users.filter(x=>(!status||x.status===status)&&(!country||x.country===country)&&(!query||[x.email,x.full_name,x.country,x.distributor_name].some(t=>String(t||'').toLowerCase().includes(query))));
 $('count').textContent=selected.length+' of '+users.length+' users';
 $('users').replaceChildren();
 for(const user of selected){
  const item=document.createElement('div');item.className='row';
  const name=document.createElement('strong');name.textContent=user.full_name||user.email;item.appendChild(name);
  const detail=document.createElement('p');detail.className='muted';detail.textContent=[user.email,user.country,user.employment_type,user.distributor_name,user.role,user.status].filter(Boolean).join(' · ');item.appendChild(detail);
  if(user.role!=='super_admin'){
   const actions=document.createElement('div');actions.className='actions';
   for(const [status,label,cls] of [['active','Approve / Activate',''],['rejected','Reject','danger'],['suspended','Suspend','danger']]){
    if(user.status===status)continue;
    const button=document.createElement('button');button.textContent=label;button.className=cls;
    button.onclick=()=>setStatus(user,status,button);actions.appendChild(button);
   }item.appendChild(actions);
  }$('users').appendChild(item);
 }
}
async function setStatus(user,status,button){
 if(!confirm('Set '+user.email+' to '+status+'?'))return;
 button.disabled=true;
 const {error}=await sb.rpc('csp_admin_set_status',{target_user_id:user.user_id,new_status:status});
 if(error){$('message').textContent='Update failed: '+error.message;button.disabled=false;return}
 await refresh();
}
$('signout').onclick=async()=>{await sb.auth.signOut();window.location.replace('./')};
$('reload').onclick=refresh;
for(const id of ['search','status','country'])$(id).addEventListener(id==='search'?'input':'change',render);
init();
