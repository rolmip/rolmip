function varargout = rolmip_check_session(action,varargin)
% Internal collector used by public session APIs and class dispatch methods.
% Stored data are metadata/issue locations only, never symbolic expressions.
persistent state active token
if isempty(active),active=false;end
switch action
 case 'active'
  varargout{1}=active;return
 case 'begin'
  if active,warning('ROLMIP:CheckRestarted','Restarting diagnostic collection discards the preceding report.');end
  state=struct('active',true,'elapsed_seconds',0,'condition_count',0, ...
   'has_errors',false,'has_warnings',false,'error_groups',0,'warning_groups',0, ...
   'conditions',struct('id',{},'name',{},'relation',{},'source',{},'monomials',{},'vertices',{},'degree',{},'dimensions',{},'construction_failed',{}), ...
   'issues',struct('condition_id',{},'severity',{},'code',{},'message',{},'locations',{}));
  active=true;token=tic;return
 case {'report','end'}
  if isempty(state)|| (strcmp(action,'end')&&~active)
   error('ROLMIP:CheckNotStarted','Call rolmip_check_begin before collecting diagnostics.');
  end
  if active,state.elapsed_seconds=toc(token);end
  if strcmp(action,'end'),active=false;end
  state.active=active;varargout{1}=state;return
end
if ~active,varargout{1}=[];return;end
[source,strict]=caller_source;
switch action
 case 'pair'
  lhs=struct(varargin{1});rhs=struct(varargin{2});relation=varargin{3};
  if ~isempty(strict),relation=strict;end
  name=sprintf('%s %s %s',lhs.label,relation,rhs.label);
  id=add_condition(name,relation,source,numel(lhs.data));
  try
   p=struct(lhs);q=struct(rhs);
   for k=1:numel(p.data),p.data(k).value=p.data(k).value-q.data(k).value;end
   p.dims=size(p.data(1).value);
   consume(id,rolmip_check(p,'lmi',true));
  catch err,diagnostic_failure(id,err);end
 case 'blocks'
  T=varargin{1};relation=varargin{2};
  for k=1:numel(T),if isa(T{k},'rolmipvar'),T{k}=struct(T{k});end;end
  id=add_condition('Block LMI',relation,source,numel(T{1,1}.data));
  try
   p=struct(T{1,1});
   for k=1:numel(p.data)
    rows=cell(1,size(T,1));
    for i=1:size(T,1)
     cells=cell(1,size(T,2));
     for j=1:size(T,2),cells{j}=T{i,j}.data(k).value;end
     rows{i}=cat(2,cells{:});
    end
    p.data(k).value=cat(1,rows{:});
   end
   p.dims=size(p.data(1).value);
   consume(id,rolmip_check(p,'lmi',true));
  catch err,diagnostic_failure(id,err);end
 case 'record'
  r=varargin{1};relation=varargin{2};name=varargin{3};
  id=add_condition(name,relation,source,r.stored_monomials);consume(id,r);
 case 'failure'
  err=varargin{1};relation=varargin{2};id=varargin{3};
  if isempty(id),id=add_condition('Construction failed',relation,source,0);end
  state.conditions(id).construction_failed=true;
  add_issue(id,'error','ConstructionFailure',sprintf('%s: %s',err.identifier,err.message),0,0);
 otherwise
  error('ROLMIP:CheckAction','Unknown internal diagnostic action.');
end
varargout{1}=id;
    function id=add_condition(name,relation,source,n)
        id=numel(state.conditions)+1;
        state.conditions(id)=struct('id',id,'name',name,'relation',relation,'source',source, ...
            'monomials',n,'vertices',[],'degree',[],'dimensions',[],'construction_failed',false);
        state.condition_count=id;
        if any(strcmp(relation,{'>','<'}))
            add_issue(id,'warning','StrictInequality','Strict inequality is converted to a non-strict constraint.',0,0);
        end
    end
    function consume(id,r)
        state.conditions(id).vertices=r.vertices;
        state.conditions(id).degree=r.degree;
        state.conditions(id).dimensions=r.dimensions;
        for k=1:numel(r.issues)
            e=r.issues(k);add_issue(id,e.severity,e.code,e.message,e.coefficient,e.simplex);
        end
    end
    function diagnostic_failure(id,err)
        add_issue(id,'error','DiagnosticFailure', ...
            sprintf('The diagnostic could not inspect this condition: %s',err.message),0,0);
    end
    function add_issue(id,severity,code,message,k,j)
        idx=find([state.issues.condition_id]==id & strcmp({state.issues.severity},severity) & strcmp({state.issues.code},code),1);
        if isempty(idx)
            state.issues(end+1)=struct('condition_id',id,'severity',severity,'code',code,'message',message,'locations',[k j]);
            if strcmp(severity,'error'),state.error_groups=state.error_groups+1;state.has_errors=true;
            elseif strcmp(severity,'warning'),state.warning_groups=state.warning_groups+1;state.has_warnings=true;end
        else
            state.issues(idx).locations=unique([state.issues(idx).locations;k j],'rows','stable');
        end
    end
end
function [source,strict]=caller_source
stack=dbstack('-completenames');root=fileparts(mfilename('fullpath'));
names={'rolmip_check_session.m','rolmip_lmi.m','construct_lmi.m','construct_lmi_terms.m'};
internal=cellfun(@(n)fullfile(root,n),names,'UniformOutput',false);
names={'ge.m','le.m','gt.m','lt.m','construct_lmi.m','construct_lmi_terms.m','construct_lmi_terms_codegen.m'};
internal=[internal,cellfun(@(n)fullfile(root,'@rolmipvar',n),names,'UniformOutput',false)];
source=struct('file','','line',0,'function','command window');strict='';
for k=1:numel(stack)
    if strcmp(stack(k).file,fullfile(root,'@rolmipvar','gt.m')),strict='>';end
    if strcmp(stack(k).file,fullfile(root,'@rolmipvar','lt.m')),strict='<';end
    if ~any(strcmp(stack(k).file,internal)) && isempty(source.file)
        source=struct('file',stack(k).file,'line',stack(k).line,'function',stack(k).name);
    end
end
end
