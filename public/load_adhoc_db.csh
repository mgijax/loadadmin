#!/bin/csh -f

#
# Loads Ad Hoc SQL database from backup
# Adds Ad Hoc SQL users to database
# Removes unnecessary tables
#
# Usage:  load_adhoc_db.csh
#

# retain 
# account?	login		name			email
#
# yes		mouseblast     Mouseblast login		DBPASSWORD:  mouseblast
# yes		rpp            Rick Palazola		rpp@jax.org
# yes		edgerton       Mary E. Edgerton		edgerton@mail.med.upenn.edu
# err		snyder         Eric Snyder		eesynder@genomica.com
# err		petrov         Sergey Petrov		ptv@druid.epm.ornl.gov
# err		evansm         Mark Evans		evansm@invitrogen.com 
# ?		peterli        Peter Li			peterli@gdb.org       
# ?		aturchin       Alex Turchin		aturchin@welchlink.welch.jhu.edu
# yes		eckmab00       Barbara Eckman		baeckman@us.ibm.com
# yes 		zhongli        Zhong Li			Zhong_Li-1@sbphrd.com
# yes		jianlu         Jian Lu			jianlu@mcw.edu
# err		jchen          James Chen		jchen@TERI.BIO.UCI.EDU
# err		bloomqui       Eric Bloomquist 		bloomqui@helix.mgh.harvard
# no 8/30/00	junping        Junping Jing		Junping_2_Jing@sbphrd.com
# yes		dhoughton      Derek Houghton		d.houghton@hgu.mrc.ac.uk (TR 2073)
# yes		mwasnick       Mike Wasnick		MikeWasnick@Chiroscience.com (TR 2112)
# yes		hpeng	       Hui Peng			phui_99@yahoo.com (TR 2234) 
# yes		karls	       Karl Schweighofer	karls@incyte.com (TR 2552)
# yes		vm	       Valeria Malinchik	vm@jax.org
# yes		cevans	       Carl Evans		c.evans@mdx.ac.uk (TR 3286)
# yes           jfryan         Joseph Ryan              jfryan@bu.edu (TR 3329)
# yes           gcolby         Glenn Colby              gcolby@mdibl.org (TR 3351)
# yes           bdb            Bernard de Bono		bdb@mrc-lmb.cam.ac.uk (TR 3353)
# yes           ppetrov        Peter Petrov		petrov_peter@mail.bg (TR 3412)
# yes		kelly	       Sherrie Kelly		kelly@mshri.on.ca
# yes		roberg	       Kevin roberg-Pereaz	roberg@mail.ahc.umn.edu (TR 3647)
# yes		bzring	       Brian Ring		bzring@appliad-genomics.com (TR 3652)
# yes           swagner        Stefan Wagner            s.wagner@hw.ac.uk (TR 4017)
# yes           ltang          Lianhong Tang            l.tang@vanderbilt.edu (TR 4228)
# yes           lhunter        Larry Hunter             larry.hunter@uchsc.edu (TR 4423)
# yes           amiller        Abigail Miller           amiller@jax.org (TR 4608)
# yes           nhong          Nancy Hong               nancy.hong@phenomixcorp.com (TR 4645)
# yes           mtaylor        Martin Taylor            martin.taylor@well.ox.ac.uk (TR 4716)
# yes           atlas          Mouse Atlas              ab@macs.hw.ac.uk (TR 4885)
# yes           crabtree       Jonathan Crabtree        crabtree@pcbi.upenn.edu (TR 4935)
# yes           horevguy       Guy Horev        	horevguy@post.tau.ac.il (TR 4996)
# yes		magnus	       Magnus Ferrier		magnus@nesc.ac.uk (TR 5117)
# yes		dakter	       Taewoo Ryu		dakter179@if.kaist.ac.kr (TR 5194)
# yes		gulban	       Omid Gulban		gulban@sickkids.ca (TR 5212)
# yes		kahraman       Abdullah Kahraman	abdullah.kahraman@tg.fh-giessen.de(TR 5219)
# yes		yhw            Yong Woo  		yhw@jax.org (TR 5308)
# yes		cjd	       Chuck Donnelly  		cjd@jax.org (TR 53??)
# yes		rkc	       Keira Curtis  		rkc24@cam.ac.uk (TR 5389)
# yes		jwilson	       John Wilson  		john.wilson@cis.strath.ac.uk(TR 5620)
# yes		jlp	       Janet L. Pereira  	jlb@jax.org (TR ????)
# yes		adie	       Euan Adie	  	euan.adie@ed.ac.uk (TR 5646)
# yes		laxman	       Lakshmanan Iyer  	laxman@cgr.harvard.edu (TR 5650)
# yes		wgong	       Wuming Gong  		gongwuming@hotmail.com (TR 5683)
# yes		qzhang	       Qing Zhang  		qing.zhang@spcorp.com (TR 5688)
# yes		janker	       Janet Anker  		janker@jax.org (TR 5738)
# yes		xinli	       Xin Li  			xin_li@umbc.edu (TR 5882)
# yes		bridges        Derek Houghton		derekh@dcs.gla.ac.uk (TR 5983)
# yes		anord          Alex Nord		an1@sanger.ac.uk (TR 6072)
# yes		csimons        Cas Simons		c.simons@imb.uq.edu.au (TR 6094)
# yes		msantos        Marcel Santos		msantos@lncc.br (TR 6148)
# yes		csb            Carolyn Blake		csb@jax.org (TR 6229)
# yes		badr           Badr al-Daihani		badr@cs.cf.ac.uk (TR 6248)
# yes		dlfulton       Debra Fulton		dlfulton@sfu.ca (TR 6254)
# yes		dwang          Degeng Wang		dwang@sdsc.edu (TR 6272)
# yes		jjgalvez       Jose Galvez		jjgalvez@ucdavis.edu (TR 6372)
# yes		mneira         Mauricio Neira		mneira@vanhosp.bc.ca (TR 6472)
# yes		nesanet        Nesanet Mitiku		nesanet@stanford.edu (TR 6486)
# yes		amcowiti       Apollo Mcowiti		amcowiti@bcm.tmc.edu (TR 6530)
# yes		ar345          Dr. Audrey Rzhetsky	ar345@columbia.edu (TR 6659)
# yes		kent           Jim Kent			kent@soe.ucsc.edu (TR 6660)
# yes		wwalke         Wade Walke		wwalke@lexgen.com (TR 6679)
# yes		fiqbal         Fatima Iqbal		libpes137@hotmail.com (TR 6710)
# yes		asia           Asia Jakubowska		asia@dcs.gla.ac.uk (TR 6711)
# yes		samb           Sam Billakanti		sam.billakanti@sanofi-aventis.com (TR 6734)
# yes		gopalp         Gopal Peddinti		ext-gopal.peddinti@vtt.fi (TR 6748)
# yes		cto	       Christine To		cto@mshri.on.ca (TR 6787)
# yes		mzhou3	       Mi Zhou			mzhou3@utmem.edu (TR 6821)
# yes		amuro	       Andrew Muro		andrew.muro@uconn.edu (TR 6838)
# yes		zhu	       Zhiliang Hu		zhu@iastate.edu (TR 6795)
# yes		peter	       Peter Killisperger	peter@killisperger.de (TR 6864)
# yes		stuart	       Dr. Stuart Aitken	stuart@inf.ed.ac.uk (TR 6883)
# yes		birn	       BIRN Amarnath Gupta 	gupta@sdsc.edu 
# yes		eberlein       Jens Eberlein		jens.eberlein@uchsc.edu (TR 6984)
# yes		fanhsu         Fan Hsu  		fanhsu@soe.ucsc.edu (TR 7175)
# yes		waltsbm        Brandon Walts  		waltsbm@pbrc.edu (TR 7258)
# yes		ryang          Roanne Yang  		waxapl622@yahoo.com.tw (TR 7264)
# yes		ypouliot       Yannick Pouloit 		ypouliot@rcn.com (TR 7304)
# yes		ncicb          NCI Bioinformatics 	guruswamis@mail.nih.gov (TR 7384)
# yes		apico          Alexander Pico   	apico@gladstone.ucsf.edu (TR 7479)
# yes		gimenez        Gregory Gimenez 		gimenez@ibdm.univ-mrs.fr (TR 7491)
# yes		gberriz        Gabriel F. Berriz 	gberriz@hms.harvard.edu (TR 7525)
# yes		valdar         Dr. William Valdar 	valdar@well.ox.ac.uk (TR 7616)
# yes		pmckenna       Paul McKenna 		paul@pmckenna.net (TR 7672)
# yes		lnh            Lucie Hutchins 		lucie.hutchins@jax.org (TR 7840)
# yes		dow            Dave Walton 		dave.walton@jax.org (TR 7840)
# yes		mec            Malcolm Cook 		mec@stowers-institute.org (TR 7840)
# yes		akavia         Uri David Akavia		uridavid@post.tau.ac.il (TR 7928)
# yes		shatkay        Hagit Shatkay		shatkay@cs.queensu.ca (TR 8003)
# yes		henrich        Thorsten Henrich		henrich@embl.de (TR 8172)
# yes		saitken        Stuart Aitken		stuart@inf.ed.ac.uk (TR 8326)
# yes		njimen         Natalia Jimenez		natalia.jimenez@pcm.uam.es (TR 8376)
# yes		dayacw         Daya C Wimalasuriya	dayacw@cs.uoregon.edu (TR ?)
# no		pargent        Walter Pargent	        walter.pargent@gsf.de (TR 8631)
# yes		ablake         Andrew Blake	        a.blake@har.mrc.ac.uk (TR 8768)
# yes		escott         Eric Scott	        eric.scott@roche.com (TR 8839)
# yes		jshah          Jyoti Shah	        jyoti_shah@merck.com (TR 8879)
# yes		karchin        Rachel Karchin	        karchin@jhu.edu (TR 8906)
# yes		payette        Paul Payette	        paul_payette@merck.com (TR 8938)
# yes		ccpark         Christopher Park	        ccpark@ucla.edu (TR 8953)
# yes		aghazalp       Anatole Ghazalpour       aghazalp@ucla.edu (TR 8953)
# yes		cjm            Chris Mungall            cjm@fruitfly.org (TR 8990)
# yes		vvi            Vivek Iyer               vvi@sanger.ac.uk (TR 9077)
# yes		kclement       kendell Clement          fatty@byu.net (TR 9111)
# yes		alexe          Alex Ellison             alex.ellison@jax.org (TR 9137)
# yes		harr           Bettina Harr             harr@evolbio.mpg.de (TR 9181)
# yes		jroux          Julien Roux              julien.roux@unil.ch (TR 9214)
# yes		cjfields       Christopher Fields       cjfields@illinois.edu (TR 9226)
# yes		iwasaki        Tsuyoshi Iwasaki         typn.jp@gmail.com (TR 9304)
# yes		ggeca          Georgi Georgiev          ggeca@bas.bg (TR 9317)
# yes		shenorr        Shai Shen-Orr            shenorr@stanford.edu (TR )
# yes		abutte         Atul Butte               abutte@stanford.edu (TR 9342 )
# yes		marah          Mara Hartsperger         mara.hartsperger@helmholtz-muenchen.de (TR 9353)
# yes		aszodi         Andras Aszodi            aszodi@imp.ac.at (TR 9354)
# yes		stanford       Yannick Pouliot          ypouliot@stanford.edu (TR 9382)
# yes		yhchen         Yan Hau Chen             hwd@ibms.sinica.edu.tw (TR 9390)
# yes		nif            Vadim Astakhov           astakhov@ncmir.ucsd.edu (TR 9443)
# yes		jlerman        Jeffrey C. Lerman        jlerman@ingenuity.com (TR 9511)
# yes		hillerm        Michael Hiller           hillerm@stanford.edu (TR 9553)
# yes		balemanm       Boanerges Aleman-Meza    balemanm@upv.edu.mx (TR 9565)
# yes		myers          David Myers              myers@myologygroup.net (TR 9559)
# yes		pradeeps       Pradeep Kumar            pradeeps@gist.ac.kr (TR 9581)
# yes		hemphill       Edward Hemphill III      edward.hemphill_iii@uconn.edu (TR 9633)
# yes		rivers         Adam Rivers              rivers@mit.edu (TR 9686)
# yes		casuso         Maguys Casuso            mcasuso@med.miami.edu (TR 9696)
# yes		scoles         Jonathan Scoles          scoles@gmail.com (TR 9739)
# yes		cmao           Chunhong Mao             cmao@vbi.vt.edu (TR 9898)
# yes		txue           Tian Xue                 txue@vbi.vt.edu (TR 9916)
# yes		sullivan       Dan Sullivan             dsulliva@vbi.vt.edu (TR 9979)
# yes		idiboun        Ilhem Diboun             idiboun@biochem.ucl.ac.uk (TR 9981)
# yes		jlegato        John Legato              jlegato@helix.nih.gov (TR 10063)
# yes		alehman        Alan Lehman              alehman@ingenuity.com (TR 10139)
# yes		states         David States             david.j.states@uth.tmc.edu (TR 10169)
# yes		poudel         Sagar Poudel             (TR 10169)
# yes		calpan         Calvin Pan            	calpan@ucla.edu (TR 10225) 
# yes		stozer         Sean Tozer            	sean.tozer@phenogenomics.ca (TR 10239) 
# yes		kdowell        Karen Dowell            	karen.dowell@maine.edu (TR 10256) 
# yes		gilberto       Gilberto da Gente 	gilberto@dagente.net (TR 10324) 
# yes		pandyas        Sima Pandya      	pandyas@mail.nih.gov (TR 10493) 
# yes		ulrike         Ulli Wagner      	ulrike@mail.nih.gov (TR 10500) 
# yes		cfellin        Campion Fellin      	cfellin@kineta.us (TR 10518) 
# yes		sgreen         Simon Greenaway      	s.greenaway@har.mrc.ac.uk (TR 10547) 
# yes		fchan          Frank Chan        	frank.chan@evolbio.mpg.de (TR 10565) 
# yes		cartic         Cartic Ramakrishnan     	cartic@isi.edu (TR 10566) 
# yes		jjay           Jeremy Jay       	jeremy.jay@jax.org (TR 10596) 
# yes		ym             Yoshiki Mochizuki     	ym@base.riken.jp (TR 10610) 
# yes           salgado        David Salgado            david.salgado@monash.edu (TR 10678)

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

setenv MGD_BACKUP /lindon/sybase/mgd.backup

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" | tee -a ${LOG}
env | sort | tee -a ${LOG}

#
# Wait for the "MGD Backup Ready" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "MGD Backup Ready" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PUB}/getFlag ${NS_ADHOC_LOAD} ${FLAG_MGD_BACKUP}`
    setenv ABORT `${PROC_CTRL_CMD_PUB}/getFlag ${NS_ADHOC_LOAD} ${FLAG_ABORT}`

    if (${READY} == 1 || ${ABORT} == 1) then
        break
    else
        sleep ${PROC_CTRL_WAIT_TIME}
    endif

    setenv RETRY `expr ${RETRY} - 1`
end

#
# Terminate the script if the number of retries expired or the abort flag
# was found.
#
if (${RETRY} == 0) then
   echo "${SCRIPT_NAME} timed out" | tee -a ${LOG}
   date | tee -a ${LOG}
   exit 1
else if (${ABORT} == 1) then
   echo "${SCRIPT_NAME} aborted by process controller" | tee -a ${LOG}
   date | tee -a ${LOG}
   exit 1
endif

#
# Clear the "MGD Backup Ready" flag.
#
date | tee -a ${LOG}
echo 'Clear process control flag: MGD Backup Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/clearFlag ${NS_ADHOC_LOAD} ${FLAG_MGD_BACKUP} ${SCRIPT_NAME}

#
# Load MGD database and delete private data.
#
date | tee -a ${LOG}
echo 'Load MGD database and delete private data' | tee -a ${LOG}
${MGI_DBUTILS}/bin/load_db.csh ${ADHOC_DBSERVER} ${ADHOC_DBNAME} ${MGD_BACKUP} deleteprivate

#
# Drop all editors and progs users from database.
#
date | tee -a ${LOG}
echo 'Drop all users' | tee -a ${LOG}
${LOADADMIN}/public/dropallusers.csh ${ADHOC_DBSERVER} ${ADHOC_DBNAME}

#
# Add Ad Hoc users.
#
date | tee -a ${LOG}
echo 'Add all users' | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${ADHOC_DBSERVER} ${ADHOC_DBNAME} $0

use ${ADHOC_DBNAME}
go

sp_adduser 'mgd_dbo'
go

sp_adduser 'mgd_public', @grpname = 'public'
go

sp_dropuser 'mouseblast'
go

sp_adduser 'mouseblast', @grpname = 'public'
go

sp_adduser 'rpp', @grpname = 'public'
go

sp_adduser 'edgerton', @grpname = 'public'
go

sp_adduser 'jianlu', @grpname = 'public'
go

sp_adduser 'zhongli', @grpname = 'public'
go

sp_adduser 'dhoughton', @grpname = 'public'
go

sp_adduser 'mwasnick', @grpname = 'public'
go

sp_adduser 'hpeng', @grpname = 'public'
go

sp_adduser 'eckmab00', @grpname = 'public'
go

sp_adduser 'karls', @grpname = 'public'
go

sp_adduser 'vm', @grpname = 'public'
go

sp_adduser 'cevans', @grpname = 'public'
go

sp_adduser 'jfryan', @grpname = 'public'
go

sp_adduser 'gcolby', @grpname = 'public'
go

sp_adduser 'bdb', @grpname = 'public'
go

sp_adduser 'ppetrov', @grpname = 'public'
go

sp_adduser 'kelly', @grpname = 'public'
go

sp_adduser 'roberg', @grpname = 'public'
go

sp_adduser 'bzring', @grpname = 'public'
go

sp_adduser 'swagner', @grpname = 'public'
go

sp_adduser 'ltang', @grpname = 'public'
go

sp_adduser 'lhunter', @grpname = 'public'
go

sp_adduser 'amiller', @grpname = 'public'
go

sp_adduser 'nhong', @grpname = 'public'
go

sp_adduser 'mtaylor', @grpname = 'public'
go

sp_adduser 'atlas', @grpname = 'public'
go

sp_adduser 'crabtree', @grpname = 'public'
go

sp_adduser 'horevguy', @grpname = 'public'
go

sp_adduser 'magnus', @grpname = 'public'
go

sp_adduser 'dakter', @grpname = 'public'
go

sp_adduser 'gulban', @grpname = 'public'
go

sp_adduser 'kahraman', @grpname = 'public'
go

sp_adduser 'yhw', @grpname = 'public'
go

sp_adduser 'cjd', @grpname = 'public'
go

sp_adduser 'rkc', @grpname = 'public'
go

sp_adduser 'jwilson', @grpname = 'public'
go

sp_adduser 'jlp', @grpname = 'public'
go

sp_adduser 'adie', @grpname = 'public'
go

sp_adduser 'laxman', @grpname = 'public'
go

sp_adduser 'wgong', @grpname = 'public'
go

sp_adduser 'qzhang', @grpname = 'public'
go

sp_adduser 'janker', @grpname = 'public'
go

sp_adduser 'xinli', @grpname = 'public'
go

sp_adduser 'bridges', @grpname = 'public'
go

sp_adduser 'anord', @grpname = 'public'
go

sp_adduser 'csimons', @grpname = 'public'
go

sp_adduser 'msantos', @grpname = 'public'
go

sp_adduser 'csb', @grpname = 'public'
go

sp_adduser 'badr', @grpname = 'public'
go

sp_adduser 'dlfulton', @grpname = 'public'
go

sp_adduser 'dwang', @grpname = 'public'
go

sp_adduser 'jjgalvez', @grpname = 'public'
go

sp_adduser 'mneira', @grpname = 'public'
go

sp_adduser 'nesanet', @grpname = 'public'
go

sp_adduser 'amcowiti', @grpname = 'public'
go

sp_adduser 'ar345', @grpname = 'public'
go

sp_adduser 'kent', @grpname = 'public'
go

sp_adduser 'wwalke', @grpname = 'public'
go

sp_adduser 'fiqbal', @grpname = 'public'
go

sp_adduser 'asia', @grpname = 'public'
go

sp_adduser 'samb', @grpname = 'public'
go

sp_adduser 'gopalp', @grpname = 'public'
go

sp_adduser 'cto', @grpname = 'public'
go

sp_adduser 'mzhou3', @grpname = 'public'
go

sp_adduser 'amuro', @grpname = 'public'
go

sp_adduser 'zhu', @grpname = 'public'
go

sp_adduser 'peter', @grpname = 'public'
go

sp_adduser 'stuart', @grpname = 'public'
go

sp_adduser 'birn', @grpname = 'public'
go

sp_adduser 'eberlein', @grpname = 'public'
go

sp_adduser 'fanhsu', @grpname = 'public'
go

sp_adduser 'waltsbm', @grpname = 'public'
go

sp_adduser 'ryang', @grpname = 'public'
go

sp_adduser 'ypouliot', @grpname = 'public'
go

sp_adduser 'ncicb', @grpname = 'public'
go

sp_adduser 'apico', @grpname = 'public'
go

sp_adduser 'gimenez', @grpname = 'public'
go

sp_adduser 'gberriz', @grpname = 'public'
go

sp_adduser 'valdar', @grpname = 'public'
go

sp_adduser 'pmckenna', @grpname = 'public'
go

sp_adduser 'lnh', @grpname = 'public'
go

sp_adduser 'dow', @grpname = 'public'
go

sp_adduser 'mec', @grpname = 'public'
go

sp_adduser 'akavia', @grpname = 'public'
go

sp_adduser 'shatkay', @grpname = 'public'
go

sp_adduser 'henrich', @grpname = 'public'
go

sp_adduser 'saitken', @grpname = 'public'
go

sp_adduser 'njimen', @grpname = 'public'
go

sp_adduser 'dayacw', @grpname = 'public'
go

sp_adduser 'ablake', @grpname = 'public'
go

sp_adduser 'escott', @grpname = 'public'
go

sp_adduser 'jshah', @grpname = 'public'
go

sp_adduser 'karchin', @grpname = 'public'
go

sp_adduser 'payette', @grpname = 'public'
go

sp_adduser 'ccpark', @grpname = 'public'
go

sp_adduser 'aghazalp', @grpname = 'public'
go

sp_adduser 'cjm', @grpname = 'public'
go

sp_adduser 'vvi', @grpname = 'public'
go

sp_adduser 'kclement', @grpname = 'public'
go

sp_adduser 'alexe', @grpname = 'public'
go

sp_adduser 'harr', @grpname = 'public'
go

sp_adduser 'jroux', @grpname = 'public'
go

sp_adduser 'cjfields', @grpname = 'public'
go

sp_adduser 'iwasaki', @grpname = 'public'
go

sp_adduser 'ggeca', @grpname = 'public'
go

sp_adduser 'shenorr', @grpname = 'public'
go

sp_adduser 'abutte', @grpname = 'public'
go

sp_adduser 'marah', @grpname = 'public'
go

sp_adduser 'aszodi', @grpname = 'public'
go

sp_adduser 'stanford', @grpname = 'public'
go

sp_adduser 'yhchen', @grpname = 'public'
go

sp_adduser 'nif', @grpname = 'public'
go

sp_adduser 'jlerman', @grpname = 'public'
go

sp_adduser 'hillerm', @grpname = 'public'
go

sp_adduser 'balemanm', @grpname = 'public'
go

sp_adduser 'myers', @grpname = 'public'
go

sp_adduser 'pradeeps', @grpname = 'public'
go

sp_adduser 'hemphill', @grpname = 'public'
go

sp_adduser 'rivers', @grpname = 'public'
go

sp_adduser 'casuso', @grpname = 'public'
go

sp_adduser 'scoles', @grpname = 'public'
go

sp_adduser 'cmao', @grpname = 'public'
go

sp_adduser 'txue', @grpname = 'public'
go

sp_adduser 'sullivan', @grpname = 'public'
go

sp_adduser 'idiboun', @grpname = 'public'
go

sp_adduser 'jlegato', @grpname = 'public'
go

sp_adduser 'alehman', @grpname = 'public'
go

sp_adduser 'states', @grpname = 'public'
go

sp_adduser 'poudel', @grpname = 'public'
go

sp_adduser 'calpan', @grpname = 'public'
go

sp_adduser 'stozer', @grpname = 'public'
go

sp_adduser 'kdowell', @grpname = 'public'
go

sp_adduser 'gilberto', @grpname = 'public'
go

sp_adduser 'pandyas', @grpname = 'public'
go

sp_adduser 'ulrike', @grpname = 'public'
go

sp_adduser 'cfellin', @grpname = 'public'
go

sp_adduser 'sgreen', @grpname = 'public'
go

sp_adduser 'fchan', @grpname = 'public'
go

sp_adduser 'cartic', @grpname = 'public'
go

sp_adduser 'jjay', @grpname = 'public'
go

sp_adduser 'ym', @grpname = 'public'
go

sp_adduser 'salgado', @grpname = 'public'
go

checkpoint
go

EOSQL

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
