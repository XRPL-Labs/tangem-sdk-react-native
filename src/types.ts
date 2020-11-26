export enum Settings {
  IsReusable = "IsReusable",
  UseActivation = "UseActivation",
  ProhibitPurgeWallet = " ProhibitPurgeWallet",
  UseBlock = "UseBlock",

  AllowSetPIN1 = "AllowSetPIN1",
  AllowSetPIN2 = "AllowSetPIN2",
  UseCvc = "UseCvc",
  ProhibitDefaultPIN1 = "ProhibitDefaultPIN1",

  UseOneCommandAtTime = "UseOneCommandAtTime",
  UseNDEF = "UseNDEF",
  UseDynamicNDEF = "UseDynamicNDEF",
  SmartSecurityDelay = "SmartSecurityDelay",

  AllowUnencrypted = "AllowUnencrypted",
  AllowFastEncryption = "AllowFastEncryption",

  ProtectIssuerDataAgainstReplay = "ProtectIssuerDataAgainstReplay",
  RestrictOverwriteIssuerExtraData = "RestrictOverwriteIssuerExtraData",

  AllowSelectBlockchain = "AllowSelectBlockchain",

  DisablePrecomputedNDEF = "DisablePrecomputedNDEF",

  SkipSecurityDelayIfValidatedByLinkedTerminal = "SkipSecurityDelayIfValidatedByLinkedTerminal",
  SkipCheckPIN2CVCIfValidatedByIssuer = "SkipCheckPIN2CVCIfValidatedByIssuer",
  SkipSecurityDelayIfValidatedByIssuer = "SkipSecurityDelayIfValidatedByIssuer",

  RequireTermTxSignature = "RequireTermTxSignature",
  RequireTermCertSignature = "RequireTermCertSignature",
  CheckPIN3OnCard = "CheckPIN3OnCard",
}

export enum CardStatus {
  NotPersonalized = "NotPersonalized",
  Empty = "Empty",
  Loaded = "Loaded",
  Purged = "Purged",
}

export enum EllipticCurve {
  secp256k1 = "secp256k1",
  ed25519 = "ed25519",
}

export enum SigningMethods {
  SignHash = "SignHash",
  SignRaw = "SignRaw",
  SignHashSignedByIssuer = "SignHashSignedByIssuer",
  SignRawSignedByIssuer = "SignRawSignedByIssuer",
  SignHashSignedByIssuerAndUpdateIssuerData = "SignHashSignedByIssuerAndUpdateIssuerData",
  SignRawSignedByIssuerAndUpdateIssuerData = "SignRawSignedByIssuerAndUpdateIssuerData",
  SignPos = "SignPos",
}

export enum Products {
  Note = "Note",
  Tag = "Tag",
  IdCard = "IdCard",
  IdIssuer = "IdIssuer",
}

export enum SetPinStatus {
  PinsNotChanged = "PinsNotChanged",
  Pin1Changed = "Pin1Changed",
  Pin2Changed = "Pin2Changed",
  Pin3Changed = "Pin3Changed",
  Pins12Changed = "Pins12Changed",
  Pins13Changed = "Pins13Changed",
  Pins23Changed = "Pins23Changed",
  Pins123Changed = "Pins123Changed",
}

export interface CardData {
  /**
   * Tangem internal manufacturing batch ID.
   */
  batchId?: String;

  /**
   * Timestamp of manufacturing.
   */
  manufactureDateTime?: Date;

  /**
   * Name of the issuer.
   */
  issuerName?: String;

  /**
   * Name of the blockchain.
   */
  blockchainName?: String;

  /**
   * Signature of CardId with manufacturer’s private key.
   */
  manufacturerSignature?: String;

  /**
   * Mask of products enabled on card.
   */
  productMask?: Products[];

  /**
   * Name of the token.
   */
  tokenSymbol?: String;

  /**
   * Smart contract address.
   */
  tokenContractAddress?: String;

  /**
   * Number of decimals in token value.
   */
  tokenDecimal?: Number;
}

export interface Card {
  /**
   * Unique Tangem card ID number.
   */
  cardId: String;

  /**
   * Name of Tangem card manufacturer.
   */
  manufacturerName: String;

  /**
   * Current status of the card.
   */
  status?: CardStatus;

  /**
   * Version of Tangem COS.
   */
  firmwareVersion?: String;

  /**
   * Public key that is used to authenticate the card against manufacturer’s database.
   * It is generated one time during card manufacturing.
   */
  cardPublicKey?: String;

  /**
   * Card settings defined by personalization
   */
  settingsMask?: Settings[];

  /**
   * Public key that is used by the card issuer to sign IssuerData field.
   */
  issuerPublicKey?: String;

  /**
   * Explicit text name of the elliptic curve used for all wallet key operations.
   * Supported curves: ‘secp256k1’ and ‘ed25519’.
   */
  curve?: EllipticCurve;

  /**
   * Total number of signatures allowed for the wallet when the card was personalized.
   */
  maxSignatures?: Number;

  /**
   * Defines what data should be submitted to SIGN command.
   */
  signingMethods?: SigningMethods[];

  /**
   * Delay in seconds before COS executes commands protected by PIN2.
   */
  pauseBeforePin2?: Number;

  /**
   * Public key of the blockchain wallet.
   */
  walletPublicKey?: String;

  /**
   * Remaining number of [SignCommand] operations before the wallet will stop signing transactions.
   */
  walletRemainingSignatures: Number;

  /**
   * Total number of signed single hashes returned by the card in
   * [SignCommand] responses since card personalization.
   * Sums up array elements within all [SignCommand].
   */
  walletSignedHashes?: Number;

  /**
   * Any non-zero value indicates that the card experiences some hardware problems.
   * User should withdraw the value to other blockchain wallet as soon as possible.
   * Non-zero Health tag will also appear in responses of all other commands.
   */
  health?: Number;

  /**
   * Whether the card requires issuer’s confirmation of activation.
   * is "true" if the card requires activation
   * is 'false" if the card is activated or does not require activation
   */
  isActivated: Boolean;

  /**
   * A random challenge generated by personalisation that should be signed and returned
   * to COS by the issuer to confirm the card has been activated.
   * This field will not be returned if the card is activated.
   */
  activationSeed?: String;

  /**
   * Returned only if [SigningMethod.SignPos] enabling POS transactions is supported by card.
   */
  paymentFlowVersion?: String;

  /**
   * This value can be initialized by terminal and will be increased by COS on execution of every [SignCommand].
   * For example this field can store blockchain “nonce” for quick one-touch transaction on POS terminals.
   * Returned only if [SigningMethod.SignPos]  enabling POS transactions is supported by card.
   */
  userCounter?: Number;

  /**
   * This value can be initialized by App (with PIN2 confirmation) and will be increased by COS
   * with the execution of each [SignCommand]. For example this field can store blockchain “nonce”
   * for a quick one-touch transaction on POS terminals. Returned only if [SigningMethod.SignPos].
   */
  userProtectedCounter?: Number;

  /**
   * When this value is true, it means that the application is linked to the card,
   * and COS will not enforce security delay if [SignCommand] will be called
   * with [TlvTag.TerminalTransactionSignature] parameter containing a correct signature of raw data
   * to be signed made with [TlvTag.TerminalPublicKey].
   */
  terminalIsLinked: Boolean;

  /**
   * Detailed information about card contents. Format is defined by the card issuer.
   * Cards complaint with Tangem Wallet application should have TLV format.
   */
  cardData?: CardData;

  sPin1Default?: Boolean;

  isPin2Default?: Boolean;
}

export type CreateWalletResponse = {
  /**
   * CID, Unique Tangem card ID number.
   */
  cardId: String;
  /**
   * Current status of the card [1 - Empty, 2 - Loaded, 3- Purged]
   */
  status: CardStatus;
  /**
   * Public key of a newly created blockchain wallet.
   */
  walletPublicKey: String;
};

export type SignResponse = {
  /**
   * CID, Unique Tangem card ID number.
   */
  cardId: String;
  /**
   * signature Signed hashes (array of resulting signatures)
   */
  signature: String[];
  /**
   * Remaining number of sign operations before the wallet will stop signing transactions.
   */
  walletRemainingSignatures: Number;
  /**
   * Total number of signed single hashes returned by the card in sign command responses.
   */
  walletSignedHashes?: Number;
};

export type PurgeWalletResponse = {
  /**
   * CID, Unique Tangem card ID number.
   */
  cardId: String;
  /**
   * Current status of the card [1 - Empty, 2 - Loaded, 3- Purged]
   */
  status: CardStatus;
};

export type SetPinResponse = {
  /**
   * CID, Unique Tangem card ID number.
   */
  cardId: String;
  /**
   *
   */
  status: SetPinStatus;
};

export type NFCStatusResponse = {
  enabled: Boolean;
  support: Boolean;
};

/**
 * Event's listeneres
 */
export type Events = "NFCStateChange";
export type EventCallback = {
  enabled: boolean;
};

export type RNTangemSdkModule = {
  scanCard(): Promise<Card>;
  createWallet(cardId: string): Promise<CreateWalletResponse>;
  purgeWallet(cardId: string): Promise<PurgeWalletResponse>;
  sign(cardId: string, hashes: string[]): Promise<SignResponse>;
  setPin1(cardId: string, pin: string): Promise<SetPinResponse>;
  setPin2(cardId: string, pin: string): Promise<SetPinResponse>;
  getNFCStatus(): Promise<NFCStatusResponse>;
};
