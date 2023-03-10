
text \<open>Authors: Anthony Bordg and Lawrence Paulson,
with some contributions from Wenda Li\<close>

theory Topological_Space
  imports Complex_Main
          Set_Theory

begin

section \<open>Topological Spaces\<close>
text \<open>p 25, def 1.1.1\<close>
locale topological_space = fixes S :: "'a set" and is_open :: "'a set \<Rightarrow> bool"
  assumes open_space [simp, intro]: "is_open S"
    and open_imp_subset: "is_open U \<Longrightarrow> U \<subseteq> S"
    and open_inter [intro]: "\<lbrakk>is_open U; is_open V\<rbrakk> \<Longrightarrow> is_open (U \<inter> V)"
    and open_union [intro]: "\<And>F::('a set) set. (\<And>x. x \<in> F \<Longrightarrow> is_open x) \<Longrightarrow> is_open (\<Union>F)"

begin

text \<open>p 25, def 1.1.1\<close>
theorem open_empty [simp, intro]: "is_open {}"
  using open_union[of "{}"] by auto

lemma open_Un [continuous_intros, intro]: "is_open U \<Longrightarrow> is_open V \<Longrightarrow> is_open (U \<union> V)"
  using open_union [of "{U, V}"] by auto

lemma openI:
  assumes "\<And>x. x \<in> U \<Longrightarrow> \<exists>T. is_open T \<and> x \<in> T \<and> T \<subseteq> U"
  shows "is_open U"
proof -
  have "is_open (\<Union>{T. is_open T \<and> T \<subseteq> U})" by auto
  moreover have "\<Union>{T. is_open T \<and> T \<subseteq> U} = U" by (auto dest!: assms)
  ultimately show "is_open U" by simp
qed

text \<open>p 30, exercise 4\<close>
lemma open_Inter [continuous_intros, intro]: "finite F \<Longrightarrow> \<forall>T\<in>F. is_open T \<Longrightarrow> is_open (S \<inter> \<Inter>F)"
  apply(induction set: finite)
  apply(auto)
  apply(subst Set.Int_assoc[symmetric])
  apply(subst Set.Int_commute[symmetric])
  apply(subst Set.Int_assoc)
  apply(rule open_inter)
  by auto
  
text \<open>p 34, def 1.2.4\<close>
definition is_closed :: "'a set \<Rightarrow> bool"
  where "is_closed U \<equiv> U \<subseteq> S \<and> is_open (S \<setminus> U)"

text \<open>p 34, def 1.2.5 i\<close>
theorem closed_empty [simp, intro]: "is_closed {}"
  by(unfold is_closed_def) (auto)

text \<open>p 34, def 1.2.5 i\<close>
theorem closed_space [simp, intro]: "is_closed S"
  by(unfold is_closed_def) (auto)

text \<open>p 34, def 1.2.5 ii\<close>
lemma closed_Inter [continuous_intros, intro]: "\<And>F::('a set) set. (\<And>x. x \<in> F \<Longrightarrow> is_closed x) \<Longrightarrow> is_closed (S \<inter> \<Inter>F)"
  unfolding is_closed_def by(auto simp add: Diff_dist[symmetric] Diff_Int_nAry simp del: Complete_Lattices.UN_simps)

text \<open>p 34, def 1.2.5 iii\<close>
lemma closed_Un [continuous_intros, intro]: "is_closed U \<Longrightarrow> is_closed V \<Longrightarrow> is_closed (U \<union> V)"
  by(unfold is_closed_def) (simp add:Set.Diff_Un open_inter)

lemma open_closed[simp]: "U \<subseteq> S \<Longrightarrow> is_closed (S \<setminus> U) \<longleftrightarrow> is_open U"
  by(simp add: is_closed_def double_diff)
  
lemma closed_open: "U \<subseteq> S \<Longrightarrow> is_closed U \<longleftrightarrow> is_open (S \<setminus> U)"
  by(simp add: is_closed_def double_diff)



text \<open>p 36, def 1.2.6\<close>
definition is_clopen :: "'a set \<Rightarrow> bool"
  where "is_clopen U \<equiv> is_open U \<and> is_closed U"

lemma open_Diff [continuous_intros, intro]: 
  assumes ou:"is_open U"
    and cv: "is_closed V"
  shows "is_open (U \<setminus> V)"
proof -
  from ou have us: "U \<subseteq> S" by (rule open_imp_subset)
  from cv have osv: "is_open (S\<setminus>V)" by (unfold is_closed_def) simp
  from osv ou have svu: "is_open ((S\<setminus>V) \<inter> U)" by (rule open_inter)
  from us svu show "is_open (U\<setminus>V)" by (subst Diff_eq_on[OF us]) (subst Set.Int_commute)
qed
  
  
lemma closed_Diff [continuous_intros, intro]: 
  assumes cu:"is_closed U" 
    and ov: "is_open V" 
  shows "is_closed (U \<setminus> V)"
proof -
  from cu have ou: "U \<subseteq> S" by (unfold is_closed_def) simp
  from cu have osu: "is_open (S\<setminus>U)" by (unfold is_closed_def) simp
  from osu ov have suv: "is_open ((S\<setminus>U) \<union> V)" by(rule open_Un)
    from suv have osu: "is_closed (S\<setminus>(S\<setminus>U \<union> V))" 
    using open_imp_subset[OF ov]
    apply(subst is_closed_def)
    apply(subst double_diff)
    by(auto)
  from osu have ssuv: "is_closed ((S\<setminus>(S\<setminus>U))\<setminus>V)" by(subst diff_as_union)
  from ssuv show "is_closed (U \<setminus> V)" 
    by(subst double_diff[OF ou, symmetric])
qed

definition neighborhoods:: "'a \<Rightarrow> ('a set) set"
  where "neighborhoods x \<equiv> {U. is_open U \<and> x \<in> U}"

text \<open>Note that by a neighborhood we mean what some authors call an open neighborhood.\<close>


lemma open_preimage_identity [simp]: "is_open B \<Longrightarrow> identity S \<^sup>\<inverse> S B = B"
  by (metis inf.orderE open_imp_subset preimage_identity_self)


definition is_connected:: "bool" where
"is_connected \<equiv> \<not> (\<exists>U V. is_open U \<and> is_open V \<and> (U \<noteq> {}) \<and> (V \<noteq> {}) \<and> (U \<inter> V = {}) \<and> (U \<union> V = S))"

definition is_hausdorff:: "bool" where
"is_hausdorff \<equiv>
\<forall>x y. (x \<in> S \<and> y \<in> S \<and> x \<noteq> y) \<longrightarrow> (\<exists>U V. U \<in> neighborhoods x \<and> V \<in> neighborhoods y \<and> U \<inter> V = {})"

end (* topological_space *)

text \<open>p 26, def 1.1.6\<close>
locale discrete_topology = topological_space +
  assumes open_discrete: "\<And>U. U \<subseteq> S \<Longrightarrow> is_open U"

text \<open>p 29, def 1.1.9\<close>
theorem singl_open_discr : 
  assumes tp:"topological_space S is_open"
  and sng:"\<And> x. x \<in> S \<Longrightarrow> is_open {x}"
  shows "discrete_topology S is_open"
proof -
  interpret S: topological_space S is_open by fact
  from tp sng show ?thesis 
    apply(unfold_locales)
    apply(rule local.S.openI)
    by(auto)
qed

text \<open>p 27, def 1.1.7\<close>
locale indiscrete_topology = topological_space +
  assumes open_discrete: "\<And>U. is_open U \<Longrightarrow> U = {} \<or> U = S"


text \<open>p 39, def 1.3.1\<close>
locale cofinite_topology = topological_space +
  assumes finite_is_closed: "\<And>U. \<lbrakk> U\<subseteq> S ; finite U \<rbrakk> \<Longrightarrow> is_closed U"
  assumes closed_is_finite: "\<And>U. is_closed U \<Longrightarrow> finite U"


text \<open>T2 spaces are also known as Hausdorff spaces.\<close>

locale t2_space = topological_space +
  assumes hausdorff: "is_hausdorff"


subsection \<open>Topological Basis\<close>

inductive generated_topology :: "'a set \<Rightarrow> 'a set set \<Rightarrow> 'a set \<Rightarrow> bool"
    for S :: "'a set" and B :: "'a set set"
  where
    UNIV: "generated_topology S B S"
  | Int: "generated_topology S B (U \<inter> V)"
            if "generated_topology S B U" and "generated_topology S B V"
  | UN: "generated_topology S B (\<Union>K)" if "(\<And>U. U \<in> K \<Longrightarrow> generated_topology S B U)"
  | Basis: "generated_topology S B b" if "b \<in> B \<and> b \<subseteq> S"

lemma generated_topology_empty [simp]: "generated_topology S B {}"
  by (metis UN Union_empty empty_iff)

lemma generated_topology_subset: "generated_topology S B U \<Longrightarrow> U \<subseteq> S"
  by (induct rule:generated_topology.induct) auto

lemma generated_topology_is_topology:
  fixes S:: "'a set" and B:: "'a set set"
  shows "topological_space S (generated_topology S B)"
  by (simp add: Int UN UNIV generated_topology_subset topological_space_def)


subsection \<open>Covers\<close>

locale cover_of_subset =
  fixes X:: "'a set" and U:: "'a set" and index:: "real set" and cover:: "real \<Rightarrow> 'a set"
(* We use real instead of index::"'b set" otherwise we get some troubles with locale sheaf_of_rings
in Comm_Ring_Theory.thy *)
  assumes is_subset: "U \<subseteq> X" and are_subsets: "\<And>i. i \<in> index \<Longrightarrow> cover i \<subseteq> X"
and covering: "U \<subseteq> (\<Union>i\<in>index. cover i)"
begin

lemma
  assumes "x \<in> U"
  shows "\<exists>i\<in>index. x \<in> cover i"
  using assms covering by auto

definition select_index:: "'a \<Rightarrow> real"
  where "select_index x \<equiv> SOME i. i \<in> index \<and> x \<in> cover i"

lemma cover_of_select_index:
  assumes "x \<in> U"
  shows "x \<in> cover (select_index x)"
  using assms by (metis (mono_tags, lifting) UN_iff covering select_index_def someI_ex subset_iff)

lemma select_index_belongs:
  assumes "x \<in> U"
  shows "select_index x \<in> index"
  using assms by (metis (full_types, lifting) UN_iff covering in_mono select_index_def tfl_some)

end (* cover_of_subset *)

locale open_cover_of_subset = topological_space X is_open + cover_of_subset X U I C
  for X and is_open and U and I and C +
  assumes are_open_subspaces: "\<And>i. i\<in>I \<Longrightarrow> is_open (C i)"
begin

lemma cover_of_select_index_is_open:
  assumes "x \<in> U"
  shows "is_open (C (select_index x))"
  using assms by (simp add: are_open_subspaces select_index_belongs)

end (* open_cover_of_subset *)

locale open_cover_of_open_subset = open_cover_of_subset X is_open U I C
  for X and is_open and U and I and C +
  assumes is_open_subset: "is_open U"


subsection \<open>Induced Topology\<close>

locale ind_topology = topological_space X is_open for X and is_open +
  fixes S:: "'a set"
  assumes is_subset: "S \<subseteq> X"
begin

definition ind_is_open:: "'a set \<Rightarrow> bool"
  where "ind_is_open U \<equiv> U \<subseteq> S \<and> (\<exists>V. V \<subseteq> X \<and> is_open V \<and> U = S \<inter> V)"

lemma ind_is_open_S [iff]: "ind_is_open S"
    by (metis ind_is_open_def inf.orderE is_subset open_space order_refl)

lemma ind_is_open_empty [iff]: "ind_is_open {}"
    using ind_is_open_def by auto

lemma ind_space_is_top_space:
  shows "topological_space S (ind_is_open)"
proof
  fix U V
  assume "ind_is_open U" then obtain UX where "UX \<subseteq> X" "is_open UX" "U = S \<inter> UX"
    using ind_is_open_def by auto
  moreover
  assume "ind_is_open V" then obtain VX where "VX \<subseteq> X" "is_open VX" "V = S \<inter> VX"
    using ind_is_open_def by auto
  ultimately have "is_open (UX \<inter> VX) \<and> (U \<inter> V = S \<inter> (UX \<inter> VX))" using open_inter by auto
  then show "ind_is_open (U \<inter> V)"
    by (metis \<open>UX \<subseteq> X\<close> ind_is_open_def le_infI1 subset_refl)
next
  fix F
  assume F: "\<And>x. x \<in> F \<Longrightarrow> ind_is_open x"
  obtain F' where F': "\<And>x. x \<in> F \<and> ind_is_open x \<Longrightarrow> is_open (F' x) \<and> x = S \<inter> (F' x)"
    using ind_is_open_def by metis
  have "is_open (\<Union> (F' ` F))"
    by (metis (mono_tags, lifting) F F' imageE open_union)
  moreover
  have "(\<Union>x\<in>F. x) = S \<inter> \<Union> (F' ` F)"
    using F' \<open>\<And>x. x \<in> F \<Longrightarrow> ind_is_open x\<close> by fastforce
  ultimately show "ind_is_open (\<Union>F)"
    by auto (metis ind_is_open_def inf_sup_ord(1) open_imp_subset)
next
  show "\<And>U. ind_is_open U \<Longrightarrow> U \<subseteq> S"
    by (simp add: ind_is_open_def)
qed auto

lemma is_open_from_ind_is_open:
  assumes "is_open S" and "ind_is_open U"
  shows "is_open U"
  using assms open_inter ind_is_open_def is_subset by auto

lemma open_cover_from_ind_open_cover:
  assumes "is_open S" and "open_cover_of_open_subset S ind_is_open U I C"
  shows "open_cover_of_open_subset X is_open U I C"
proof
  show "is_open U"
    using assms is_open_from_ind_is_open open_cover_of_open_subset.is_open_subset by blast
  show "\<And>i. i \<in> I \<Longrightarrow> is_open (C i)"
    using assms is_open_from_ind_is_open open_cover_of_open_subset_def open_cover_of_subset.are_open_subspaces by blast
  show "\<And>i. i \<in> I \<Longrightarrow> C i \<subseteq> X"
    using assms(2) is_subset
    by (meson cover_of_subset_def open_cover_of_open_subset_def open_cover_of_subset_def subset_trans)
  show "U \<subseteq> X"
    by (simp add: \<open>is_open U\<close> open_imp_subset)
  show "U \<subseteq> \<Union> (C ` I)"
    by (meson assms(2) cover_of_subset_def open_cover_of_open_subset_def open_cover_of_subset_def)
qed

end (* induced topology *)

lemma (in topological_space) ind_topology_is_open_self [iff]: "ind_topology S is_open S"
  by (simp add: ind_topology_axioms_def ind_topology_def topological_space_axioms)

lemma (in topological_space) ind_topology_is_open_empty [iff]: "ind_topology S is_open {}"
  by (simp add: ind_topology_axioms_def ind_topology_def topological_space_axioms)

lemma (in topological_space) ind_is_open_iff_open:
  shows "ind_topology.ind_is_open S is_open S U \<longleftrightarrow> is_open U \<and> U \<subseteq> S"
  by (metis ind_topology.ind_is_open_def ind_topology_is_open_self inf.absorb_iff2)

subsection \<open>Continuous Maps\<close>

locale continuous_map = source: topological_space S is_open + target: topological_space S' is_open'
+ map f S S'
  for S and is_open and S' and is_open' and f +
  assumes is_continuous: "\<And>U. is_open' U \<Longrightarrow> is_open (f\<^sup>\<inverse> S U)"
begin

lemma open_cover_of_open_subset_from_target_to_source:
  assumes "open_cover_of_open_subset S' is_open' U I C"
  shows "open_cover_of_open_subset S is_open (f\<^sup>\<inverse> S U) I (\<lambda>i. f\<^sup>\<inverse> S (C i))"
proof
  show "f \<^sup>\<inverse> S U \<subseteq> S" by simp
  show "f \<^sup>\<inverse> S (C i) \<subseteq> S" if "i \<in> I" for i
    using that by simp
  show "is_open (f \<^sup>\<inverse> S U)"
    by (meson assms is_continuous open_cover_of_open_subset.is_open_subset)
  show "\<And>i. i \<in> I \<Longrightarrow> is_open (f \<^sup>\<inverse> S (C i))"
    by (meson assms is_continuous open_cover_of_open_subset_def open_cover_of_subset.are_open_subspaces)
  show "f \<^sup>\<inverse> S U \<subseteq> (\<Union>i\<in>I. f \<^sup>\<inverse> S (C i))"
    using assms unfolding open_cover_of_open_subset_def cover_of_subset_def open_cover_of_subset_def
    by blast
qed

end (* continuous map *)


subsection \<open>Homeomorphisms\<close>

text \<open>The topological isomorphisms between topological spaces are called homeomorphisms.\<close>

locale homeomorphism =
  continuous_map + bijective_map f S S' +
  continuous_map S' is_open' S is_open "inverse_map f S S'"

lemma (in topological_space) id_is_homeomorphism:
  shows "homeomorphism S is_open S is_open (identity S)"
proof
  show "inverse_map (identity S) S S \<in> S \<rightarrow>\<^sub>E S"
    by (simp add: inv_into_into inverse_map_def)
qed (auto simp: open_inter bij_betwI')


subsection \<open>Topological Filters\<close> (* Imported from HOL.Topological_Spaces *)

definition (in topological_space) nhds :: "'a \<Rightarrow> 'a filter"
  where "nhds a = (INF S\<in>{S. is_open S \<and> a \<in> S}. principal S)"

abbreviation (in topological_space)
  tendsto :: "('b \<Rightarrow> 'a) \<Rightarrow> 'a \<Rightarrow> 'b filter \<Rightarrow> bool"  (infixr "\<longlongrightarrow>" 55)
  where "(f \<longlongrightarrow> l) F \<equiv> filterlim f (nhds l) F"

definition (in t2_space) Lim :: "'f filter \<Rightarrow> ('f \<Rightarrow> 'a) \<Rightarrow> 'a"
  where "Lim A f = (THE l. (f \<longlongrightarrow> l) A)"

end
