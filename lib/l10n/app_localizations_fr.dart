// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'E-Team - Department as a Service';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonApply => 'Appliquer';

  @override
  String get profileTitle => 'Mon profil';

  @override
  String get profileDarkMode => 'Mode sombre';

  @override
  String get profileEditProfile => 'Modifier le profil';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileTerms => 'Conditions d’utilisation';

  @override
  String get profilePrivacy => 'Politique de confidentialité';

  @override
  String get profileLogout => 'Déconnexion';

  @override
  String get profileUserDataNotAvailable => 'Données utilisateur indisponibles';

  @override
  String get profileUpdatedSuccessfully => 'Profil mis à jour avec succès !';

  @override
  String get logoutDialogTitle => 'Déconnexion';

  @override
  String get logoutDialogMessage => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSubtitle => 'Choisissez votre langue préférée';

  @override
  String get languageInfoBanner => 'La langue de l’application se met à jour immédiatement';

  @override
  String get languageApplyButton => 'Appliquer la langue';

  @override
  String get languageChangeDialogTitle => 'Changer de langue ?';

  @override
  String languageChangeDialogMessage(Object language) {
    return 'L’application passera en $language.';
  }

  @override
  String languageChangedSnack(Object language) {
    return 'Langue changée en $language';
  }

  @override
  String get commonPerHourShort => '/h';

  @override
  String get commonPerMonthShort => '/mo';

  @override
  String get agentMarketplaceWelcomeBack => 'Bon retour';

  @override
  String get agentMarketplaceNoNewNotifications => 'Aucune nouvelle notification';

  @override
  String get agentMarketplaceTitle => 'Marché des agents';

  @override
  String agentMarketplaceSwipeToExplore(Object count) {
    return 'Glissez pour explorer $count agents IA';
  }

  @override
  String get agentMarketplaceHireAgent => 'Recruter l’agent';

  @override
  String get agentMarketplaceNavMarket => 'Marché';

  @override
  String get agentMarketplaceNavAgents => 'Agents';

  @override
  String get agentMarketplaceNavStats => 'Stats';

  @override
  String get agentMarketplaceNavSettings => 'Paramètres';

  @override
  String get agentMarketplaceStatResponse => 'Réponse';

  @override
  String get agentMarketplaceStatAccuracy => 'Précision';

  @override
  String get agentMarketplaceStatLanguages => 'Langues';

  @override
  String agentMarketplacePriceFrom(Object price) {
    return 'à partir de $price';
  }

  @override
  String get agentRoleHrSpecialist => 'SPÉCIALISTE RH';

  @override
  String get agentRoleFinancialExpert => 'EXPERT FINANCIER';

  @override
  String get agentRoleAdminAssistant => 'ASSISTANT ADMIN';

  @override
  String get agentRolePlanningManager => 'RESPONSABLE PLANNING';

  @override
  String get agentRoleCommunicationPro => 'PRO DE LA COMMUNICATION';

  @override
  String get agentDescAlpha => 'Gérez les employés, suivez les congés et l’onboarding';

  @override
  String get agentDescFinanceWizard => 'Suivi des dépenses, gestion des factures, rapports financiers';

  @override
  String get agentDescAdminPro => 'Gestion de documents, classification, archivage';

  @override
  String get agentDescPlanningBot => 'Gestion des tâches, planification des réunions, deadlines';

  @override
  String get agentDescCommSync => 'Gestion des emails, notifications, résumés';

  @override
  String get agentDetailsTitle => 'Profil de l’agent';

  @override
  String agentDetailsShareSnack(Object agent) {
    return 'Partager $agent';
  }

  @override
  String agentDetailsHires(Object hires) {
    return '($hires recrutements)';
  }

  @override
  String get agentDetailsStatResponse => 'RÉPONSE';

  @override
  String get agentDetailsStatAccuracy => 'PRÉCISION';

  @override
  String get agentDetailsStatLanguages => 'LANGUES';

  @override
  String get agentDetailsCoreSkills => 'COMPÉTENCES CLÉS';

  @override
  String get agentDetailsPerformanceEfficiency => 'EFFICACITÉ DES PERFORMANCES';

  @override
  String get agentDetailsPerformanceThisWeek => '+12,4% cette semaine';

  @override
  String get agentDetailsDeploymentPlans => 'FORMULES DE DÉPLOIEMENT';

  @override
  String get agentDetailsPlanFreeTrial => 'Essai gratuit';

  @override
  String get agentDetailsPlanHourly => 'Horaire';

  @override
  String get agentDetailsPlanMonthly => 'Mensuel';

  @override
  String get agentDetailsBadgeStarter => 'DÉMARRAGE';

  @override
  String get agentDetailsBadgeBestValue => 'MEILLEUR PRIX';

  @override
  String get agentDetailsHireAgent => 'Recruter l’agent';

  @override
  String get agentDetailsHourlyPlan => 'Forfait horaire';

  @override
  String get agentDetailsMonthlyPlan => 'Forfait mensuel';

  @override
  String agentDetailsAgentHiredSnack(Object agent, Object plan) {
    return '$agent recruté avec $plan !';
  }

  @override
  String pricingRequestsPerMonth(Object count) {
    return '$count requêtes/mois';
  }

  @override
  String get pricingPayAsYouGo => 'Paiement à l’usage';

  @override
  String get pricingUnlimitedHrTasks => 'Tâches RH illimitées';

  @override
  String get pricingFullFinancialSuite => 'Suite financière complète';

  @override
  String get pricingCompleteAdminSupport => 'Support admin complet';

  @override
  String get pricingProjectManagementTools => 'Outils de gestion de projet';

  @override
  String get pricingCommunicationAutomation => 'Automatisation de la communication';

  @override
  String get pricingFullFeaturesAccess => 'Accès à toutes les fonctionnalités';

  @override
  String get agentVersionAlpha => 'Version 3.2.1 • Certifié RH';

  @override
  String get agentVersionFinanceWizard => 'Version 4.0.5 • Expert financier';

  @override
  String get agentVersionAdminPro => 'Version 2.8.3 • Spécialiste admin';

  @override
  String get agentVersionPlanningBot => 'Version 3.1.0 • Pro du planning';

  @override
  String get agentVersionCommSync => 'Version 2.9.2 • Maître communication';

  @override
  String get agentVersionDefault => 'Version 2.4.0 • Prêt pour l’entreprise';

  @override
  String get skillRecruitmentOnboarding => 'Recrutement & onboarding';

  @override
  String get skillEmployeeRecords => 'Dossiers employés';

  @override
  String get skillPayrollManagement => 'Gestion de la paie';

  @override
  String get skillLeaveTracking => 'Suivi des congés';

  @override
  String get skillPerformanceReviews => 'Évaluations de performance';

  @override
  String get skillInvoiceProcessing => 'Traitement des factures';

  @override
  String get skillExpenseTracking => 'Suivi des dépenses';

  @override
  String get skillFinancialReports => 'Rapports financiers';

  @override
  String get skillBudgetPlanning => 'Planification budgétaire';

  @override
  String get skillTaxCompliance => 'Conformité fiscale';

  @override
  String get skillDocumentManagement => 'Gestion des documents';

  @override
  String get skillFileOrganization => 'Organisation des fichiers';

  @override
  String get skillDataEntry => 'Saisie de données';

  @override
  String get skillMeetingScheduling => 'Planification des réunions';

  @override
  String get skillEmailManagement => 'Gestion des emails';

  @override
  String get skillProjectPlanning => 'Planification de projet';

  @override
  String get skillTaskManagement => 'Gestion des tâches';

  @override
  String get skillResourceAllocation => 'Allocation des ressources';

  @override
  String get skillDeadlineTracking => 'Suivi des échéances';

  @override
  String get skillTeamCoordination => 'Coordination d’équipe';

  @override
  String get skillEmailCampaigns => 'Campagnes email';

  @override
  String get skillTeamCommunications => 'Communications d’équipe';

  @override
  String get skillNotifications => 'Notifications';

  @override
  String get skillAnnouncementDistribution => 'Diffusion d’annonces';

  @override
  String get skillChatManagement => 'Gestion du chat';

  @override
  String get skillNaturalLanguage => 'Langage naturel';

  @override
  String get skillApiIntegration => 'Intégration API';

  @override
  String get skillMultilingualSupport => 'Support multilingue';

  @override
  String get skillDataAnalysis => 'Analyse de données';

  @override
  String get skillAutomation => 'Automatisation';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingWelcomeTo => 'Bienvenue sur';

  @override
  String get onboardingWelcomeSubtitle => 'Votre espace de travail IA\npour de meilleures décisions';

  @override
  String get onboardingSlideToStart => 'Glisser pour démarrer';

  @override
  String get onboardingExploreMarketplace => 'Explorer le marché';

  @override
  String get onboardingChatbotTitle => 'E-Team IA';

  @override
  String onboardingChatbotQuestionLabel(Object number) {
    return 'Question $number';
  }

  @override
  String get onboardingChatbotSelectAtLeastOne => 'Veuillez sélectionner au moins une option';

  @override
  String get onboardingChatbotContinue => 'Continuer';

  @override
  String get onboardingChatbotDiscoverMarketplace => 'Découvrir le marché';

  @override
  String onboardingChatbotPersonalizedRecommendations(Object recommendations) {
    return '✨ Recommandations personnalisées :\n\n$recommendations';
  }

  @override
  String get chatbotQRole => '👋 Ravi de vous rencontrer !\n\nQuel est votre rôle ?';

  @override
  String get chatbotQTeamSize => 'Quelle est la taille de votre équipe ?';

  @override
  String get chatbotQChallenges => 'Quels sont vos plus grands défis ?';

  @override
  String get chatbotQChallengesSubtitle => 'Sélectionnez tout ce qui s’applique';

  @override
  String get chatbotQPriority => 'Quelle est votre priorité n°1 ?';

  @override
  String get chatbotRoleCeoFounder => '👔 CEO / Fondateur';

  @override
  String get chatbotRoleManager => '📊 Manager';

  @override
  String get chatbotRoleDepartmentHead => '💼 Chef de département';

  @override
  String get chatbotRoleEmployee => '👨‍💻 Employé';

  @override
  String get chatbotRoleStudent => '🎓 Étudiant';

  @override
  String get chatbotTeamSolo => 'Solo';

  @override
  String get chatbotTeam2To5 => '2-5 personnes';

  @override
  String get chatbotTeam6To20 => '6-20 personnes';

  @override
  String get chatbotTeam21To50 => '21-50 personnes';

  @override
  String get chatbotTeam50Plus => '50+ personnes';

  @override
  String get chatbotChallengeTimeManagement => '⏰ Gestion du temps';

  @override
  String get chatbotChallengeGrowthManagement => '📈 Gestion de la croissance';

  @override
  String get chatbotChallengeCostOptimization => '💰 Optimisation des coûts';

  @override
  String get chatbotChallengeTeamCoordination => '🤝 Coordination d’équipe';

  @override
  String get chatbotChallengeDataAnalysis => '📊 Analyse de données';

  @override
  String get chatbotChallengeTaskAutomation => '🔄 Automatisation des tâches';

  @override
  String get chatbotPriorityProductivity => '🚀 Productivité';

  @override
  String get chatbotPriorityInnovation => '💡 Innovation';

  @override
  String get chatbotPriorityRevenueGrowth => '📈 Croissance du chiffre d’affaires';

  @override
  String get chatbotPriorityTeamDevelopment => '👥 Développement d’équipe';

  @override
  String get chatbotPriorityTimeSaving => '⚡ Gain de temps';

  @override
  String get chatbotRecTaskAutomationAi => '🤖 IA d’automatisation des tâches';

  @override
  String get chatbotRecTeamSyncAssistant => '👥 Assistant de synchro d’équipe';

  @override
  String get chatbotRecDataAnalyticsPro => '📊 Pro de l’analyse de données';

  @override
  String get chatbotRecSmartAssistant => '🚀 Assistant intelligent';

  @override
  String get chatbotRecAnalyticsDashboard => '📊 Tableau de bord analytics';

  @override
  String get commonUser => 'Utilisateur';

  @override
  String get commonEmailPlaceholder => 'email@exemple.com';

  @override
  String get commonUserInitial => 'U';

  @override
  String get authWelcomeBackTitle => 'Bon retour';

  @override
  String get authWelcomeBackSnack => '✅ Bon retour !';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'nom@entreprise.com';

  @override
  String get authEmailRequired => 'Entrez votre email';

  @override
  String get authEmailInvalid => 'Veuillez entrer un email valide';

  @override
  String get authPasswordLabel => 'Mot de passe';

  @override
  String get authPasswordHint => '••••••••';

  @override
  String get authPasswordRequired => 'Entrez votre mot de passe';

  @override
  String get authPasswordMin6Short => 'Min 6 caractères';

  @override
  String get authPasswordMin6 => 'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get authRememberMe => 'Se souvenir de moi';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get authOr => 'ou';

  @override
  String get authNewHere => 'Nouveau ici ? ';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authGoogleComingSoon => 'Connexion Google bientôt disponible !';

  @override
  String get authAppleComingSoon => 'Connexion Apple bientôt disponible !';

  @override
  String get authLoginNoAccount => 'Aucun compte trouvé avec cet email';

  @override
  String get authLoginIncorrectPassword => 'Mot de passe incorrect';

  @override
  String get authUnableToConnect => 'Impossible de se connecter au serveur';

  @override
  String get authLoginFailedTryAgain => 'Échec de la connexion. Veuillez réessayer.';

  @override
  String get authCreateAccountTitle => 'Créer un compte';

  @override
  String get authSignupSubtitle => 'Rejoignez-nous pour transformer votre entreprise';

  @override
  String get authFullNameLabel => 'Nom complet';

  @override
  String get authFullNameHint => 'Jean Dupont';

  @override
  String get authNameRequired => 'Veuillez entrer votre nom';

  @override
  String get authNameMin2 => 'Le nom doit contenir au moins 2 caractères';

  @override
  String get authConfirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get authConfirmPasswordRequired => 'Veuillez confirmer votre mot de passe';

  @override
  String get authPasswordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get authAcceptTermsError => 'Veuillez accepter les Conditions d’utilisation et la Politique de confidentialité';

  @override
  String get authAgreeToPrefix => 'J’accepte les ';

  @override
  String get authTermsAndConditions => 'Conditions d’utilisation';

  @override
  String get authAnd => ' et la ';

  @override
  String get authPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get authAccountCreatedCheckEmail => '✅ Compte créé ! Vérifiez votre email pour confirmer.';

  @override
  String get authEmailAlreadyRegistered => 'Cet email est déjà enregistré';

  @override
  String get authConnectionTimeout => 'Délai de connexion dépassé. Veuillez réessayer.';

  @override
  String get authAlreadyHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get authForgotPasswordTitle => 'Mot de passe\noublé ?';

  @override
  String get authForgotPasswordSubtitle => 'Pas d’inquiétude. Entrez votre email et nous vous enverrons un lien de réinitialisation.';

  @override
  String get authSendResetLink => 'Envoyer le lien';

  @override
  String get authBackToLogin => 'Retour à la connexion';

  @override
  String get authCheckYourEmailTitle => 'Vérifiez\nvotre email';

  @override
  String authResetLinkSentTo(Object email) {
    return 'Nous avons envoyé un lien de réinitialisation à\n$email';
  }

  @override
  String get authDidntReceiveResend => 'Vous ne l’avez pas reçu ? Renvoyer';

  @override
  String get authVerifyYourEmailTitle => 'Vérifiez votre email';

  @override
  String get authWeSentCodeTo => 'Nous avons envoyé un code de vérification à';

  @override
  String get authYourEmailPlaceholder => 'votre email';

  @override
  String get authVerifyEmailButton => 'Vérifier';

  @override
  String get authEnterAll6Digits => 'Veuillez saisir les 6 chiffres';

  @override
  String get authEmailMissing => 'Email manquant';

  @override
  String get authEmailVerifiedSuccess => '✅ Email vérifié avec succès !';

  @override
  String get authInvalidCodeCheckEmail => 'Code invalide. Vérifiez votre email.';

  @override
  String get authCodeExpiredRequestNew => 'Code expiré. Demandez-en un nouveau.';

  @override
  String get authEmailAlreadyVerified => 'Email déjà vérifié';

  @override
  String get authNewCodeSent => '✅ Nouveau code envoyé ! Vérifiez votre email.';

  @override
  String get authDidntReceiveCode => 'Vous n’avez pas reçu le code ? ';

  @override
  String authResendInSeconds(Object seconds) {
    return 'Renvoyer dans ${seconds}s';
  }

  @override
  String get authResendCode => 'Renvoyer le code';

  @override
  String authErrorWithDetails(Object error) {
    return '❌ Erreur : $error';
  }

  @override
  String get authEditProfileTitle => 'Modifier le profil';

  @override
  String get authNameLabel => 'Nom';

  @override
  String get authEnterYourNameHint => 'Entrez votre nom';

  @override
  String get authEnterYourEmailHint => 'Entrez votre email';

  @override
  String get authChangePassword => 'Changer le mot de passe';

  @override
  String get authCurrentPassword => 'Mot de passe actuel';

  @override
  String get authEnterCurrentPasswordHint => 'Entrez le mot de passe actuel';

  @override
  String get authCurrentPasswordRequired => 'Veuillez saisir le mot de passe actuel';

  @override
  String get authNewPassword => 'Nouveau mot de passe';

  @override
  String get authEnterNewPasswordHint => 'Entrez le nouveau mot de passe';

  @override
  String get authConfirmNewPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get authConfirmNewPasswordHint => 'Confirmez le nouveau mot de passe';

  @override
  String get authUpdateProfileButton => 'Mettre à jour';

  @override
  String get authProfileUpdatedSnack => '✅ Profil mis à jour avec succès !';

  @override
  String get helpSupportTitle => 'Aide & Support';

  @override
  String get helpSupportSubtitle => 'Nous sommes là pour vous aider';

  @override
  String get helpSupportNeedHelpTitle => 'Besoin d’aide ?';

  @override
  String get helpSupportNeedHelpDesc => 'Notre équipe support est disponible 24/7\npour vous assister';

  @override
  String get helpSupportFaqSectionTitle => 'Questions fréquentes';

  @override
  String get helpSupportContactSectionTitle => 'Nous contacter';

  @override
  String get helpSupportFaqHireQuestion => 'Comment recruter un agent IA ?';

  @override
  String get helpSupportFaqHireAnswer => 'Allez sur le Marché des agents, parcourez les agents disponibles puis appuyez sur \"Recruter l’agent\".';

  @override
  String get helpSupportFaqPaymentQuestion => 'Quels moyens de paiement acceptez-vous ?';

  @override
  String get helpSupportFaqPaymentAnswer => 'Nous acceptons les cartes bancaires (Visa, Mastercard) et les virements pour les offres entreprise.';

  @override
  String get helpSupportFaqCancelQuestion => 'Puis-je annuler mon abonnement ?';

  @override
  String get helpSupportFaqCancelAnswer => 'Oui, vous pouvez annuler à tout moment depuis les paramètres du profil. Votre accès continue jusqu’à la fin de la période de facturation.';

  @override
  String get helpSupportFaqUpdateProfileQuestion => 'Comment mettre à jour mon profil ?';

  @override
  String get helpSupportFaqUpdateProfileAnswer => 'Allez dans Profil → Modifier le profil pour mettre à jour votre nom, votre email ou votre mot de passe.';

  @override
  String get helpSupportFaqDataSecureQuestion => 'Mes données sont-elles sécurisées ?';

  @override
  String get helpSupportFaqDataSecureAnswer => 'Oui ! Nous utilisons le chiffrement de bout en bout, des connexions SSL et respectons le RGPD.';

  @override
  String get helpSupportEmailSupportTitle => 'Support email';

  @override
  String get helpSupportEmailSupportDesc => 'Réponse sous 24 heures';

  @override
  String helpSupportCopiedToClipboard(Object label) {
    return '$label copié dans le presse-papiers !';
  }

  @override
  String helpSupportComingSoon(Object label) {
    return '$label - Bientôt disponible !';
  }

  @override
  String get privacyTitle => 'Politique de confidentialité';

  @override
  String get privacySubtitle => 'Vos données sont protégées';

  @override
  String get privacyBadge => 'Conforme RGPD • Dernière mise à jour : 8 fév. 2026';

  @override
  String get privacyIntro => 'Nous respectons votre vie privée et nous nous engageons à protéger vos données personnelles.';

  @override
  String get privacySectionDataCollectedTitle => 'Données collectées';

  @override
  String get privacySectionDataCollectedSummary => 'Ce que nous recueillons';

  @override
  String get privacySectionDataCollectedContent => 'Nous collectons : informations de compte (nom, email), données d’usage, informations de l’appareil et informations de paiement.';

  @override
  String get privacySectionDataUsageTitle => 'Utilisation des données';

  @override
  String get privacySectionDataUsageSummary => 'Comment nous les utilisons';

  @override
  String get privacySectionDataUsageContent => 'Nous utilisons les données pour fournir le service, personnaliser l’expérience, traiter les paiements et assurer la sécurité.';

  @override
  String get privacySectionSecurityTitle => 'Sécurité';

  @override
  String get privacySectionSecuritySummary => 'Protection des données';

  @override
  String get privacySectionSecurityContent => 'Chiffrement de bout en bout, SSL sécurisé, audits réguliers et stockage chiffré.';

  @override
  String get privacySectionRightsTitle => 'Vos droits';

  @override
  String get privacySectionRightsSummary => 'Conformité RGPD';

  @override
  String get privacySectionRightsContent => 'Vous pouvez accéder, corriger, supprimer et exporter vos données à tout moment.';

  @override
  String get privacySectionContactDpoTitle => 'Contacter le DPO';

  @override
  String get privacySectionContactDpoSummary => 'Demandes liées à la vie privée';

  @override
  String get privacySectionContactDpoContent => '📧 privacy@e-team.com\n📧 dpo@e-team.com';

  @override
  String get privacyDownloadSnack => 'Politique téléchargée';

  @override
  String get privacyDownloadButton => 'Télécharger la politique';

  @override
  String get privacyUnderstandButton => 'J’ai compris';

  @override
  String get termsTitle => 'Conditions d’utilisation';

  @override
  String get termsSubtitle => 'Appuyez sur une section pour développer';

  @override
  String get termsBadge => 'Dernière mise à jour : 8 fév. 2026';

  @override
  String get termsSectionAcceptanceTitle => 'Acceptation';

  @override
  String get termsSectionAcceptanceSummary => 'En utilisant E-Team, vous acceptez ces conditions';

  @override
  String get termsSectionAcceptanceContent => 'En accédant à E-Team, vous acceptez ces conditions. Si vous n’êtes pas d’accord, n’utilisez pas le service.';

  @override
  String get termsSectionAiUsageTitle => 'Utilisation de l’IA';

  @override
  String get termsSectionAiUsageSummary => 'L’IA assiste, ne remplace pas le jugement';

  @override
  String get termsSectionAiUsageContent => 'Les agents IA assistent certaines tâches. Les résultats ne sont pas garantis. Vous devez valider les sorties et gérer les données de manière sécurisée.';

  @override
  String get termsSectionPaymentTitle => 'Paiement';

  @override
  String get termsSectionPaymentSummary => 'Abonnement & paiement à l’usage';

  @override
  String get termsSectionPaymentContent => 'Certaines fonctionnalités sont payantes. Les abonnements sont facturés mensuellement/annuellement. Non remboursable sauf obligation légale.';

  @override
  String get termsSectionLiabilityTitle => 'Responsabilité';

  @override
  String get termsSectionLiabilitySummary => 'Responsabilité juridique limitée';

  @override
  String get termsSectionLiabilityContent => 'E-Team n’est pas responsable des dommages indirects, pertes de profits ou pertes de données.';

  @override
  String get termsSectionContactTitle => 'Contact';

  @override
  String get termsSectionContactSummary => 'Nous contacter';

  @override
  String get termsSectionContactContent => '📧 support@e-team.com\n🌐 www.e-team.com';

  @override
  String get termsAcceptButton => 'J’ai compris & j’accepte';

  @override
  String get appInfoTitle => 'À propos d’E-Team';

  @override
  String get appInfoSubtitle => 'Informations de l’application';

  @override
  String get appInfoTagline => 'Gestion d’équipe propulsée par l’IA';

  @override
  String appInfoVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get appInfoAboutSectionTitle => 'À propos';

  @override
  String get appInfoAboutDescription => 'E-Team est une plateforme propulsée par l’IA qui aide les entreprises à gérer leurs équipes efficacement. Avec des agents IA spécialisés en RH, Finance, Admin, Planning et Communication, nous automatisons les tâches répétitives et augmentons la productivité.';

  @override
  String get appInfoFeaturesTitle => 'Fonctionnalités clés';

  @override
  String get appInfoFeaturesSubtitle => 'Ce que nous offrons';

  @override
  String get appInfoFeatureMarketplace => '🦾 Marché des agents IA';

  @override
  String get appInfoFeatureHr => '💼 Automatisation de la gestion RH';

  @override
  String get appInfoFeatureFinancial => '💰 Outils & rapports financiers';

  @override
  String get appInfoFeatureDocs => '📁 Gestion des documents';

  @override
  String get appInfoFeaturePlanning => '📅 Planification & agenda intelligents';

  @override
  String get appInfoFeatureCommunication => '📧 Assistant de communication';

  @override
  String get appInfoTechTitle => 'Stack technique';

  @override
  String get appInfoTechSubtitle => 'Construit avec des outils modernes';

  @override
  String get appInfoTechFlutter => 'Flutter - UI multiplateforme';

  @override
  String get appInfoTechNode => 'Node.js - API backend';

  @override
  String get appInfoTechMongo => 'MongoDB - Base de données';

  @override
  String get appInfoTechProvider => 'Provider - Gestion d’état';

  @override
  String get appInfoTechJwt => 'JWT - Authentification';

  @override
  String get appInfoConnectWithUs => 'RESTEZ CONNECTÉS';

  @override
  String get appInfoEmailLabel => 'Email';

  @override
  String get appInfoLegalTerms => 'Conditions d’utilisation';

  @override
  String get appInfoLegalPrivacy => 'Politique de confidentialité';

  @override
  String get appInfoLegalLicenses => 'Licences';

  @override
  String get appInfoComingSoon => 'Bientôt disponible !';

  @override
  String get appInfoLegalese => '© 2025 E-Team. Tous droits réservés.';

  @override
  String get appInfoCopyright => '© 2025 E-Team. Tous droits réservés.';

  @override
  String get appInfoMadeWith => 'Fait avec ❤️ en Tunisie 🇹🇳';
}
