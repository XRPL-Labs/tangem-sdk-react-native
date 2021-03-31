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
  batchId?: string;

  /**
   * Timestamp of manufacturing.
   */
  manufactureDateTime?: Date;

  /**
   * Name of the issuer.
   */
  issuerName?: string;

  /**
   * Name of the blockchain.
   */
  blockchainName?: string;

  /**
   * Signature of CardId with manufacturer’s private key.
   */
  manufacturerSignature?: string;

  /**
   * Mask of products enabled on card.
   */
  productMask?: Products[];

  /**
   * Name of the token.
   */
  tokenSymbol?: string;

  /**
   * Smart contract address.
   */
  tokenContractAddress?: string;

  /**
   * Number of decimals in token value.
   */
  tokenDecimal?: number;
}

export interface Card {
  /**
   * Unique Tangem card ID number.
   */
  cardId: string;

  /**
   * Name of Tangem card manufacturer.
   */
  manufacturerName: string;

  /**
   * Current status of the card.
   */
  status?: CardStatus;

  /**
   * Version of Tangem COS.
   */
  firmwareVersion?: string;

  /**
   * Public key that is used to authenticate the card against manufacturer’s database.
   * It is generated one time during card manufacturing.
   */
  cardPublicKey?: string;

  /**
   * Card settings defined by personalization
   */
  settingsMask?: Settings[];

  /**
   * Public key that is used by the card issuer to sign IssuerData field.
   */
  issuerPublicKey?: string;

  /**
   * Explicit text name of the elliptic curve used for all wallet key operations.
   * Supported curves: ‘secp256k1’ and ‘ed25519’.
   */
  curve?: EllipticCurve;

  /**
   * Total number of signatures allowed for the wallet when the card was personalized.
   */
  maxSignatures?: number;

  /**
   * Defines what data should be submitted to SIGN command.
   */
  signingMethods?: SigningMethods[];

  /**
   * Delay in seconds before COS executes commands protected by PIN2.
   */
  pauseBeforePin2?: number;

  /**
   * Public key of the blockchain wallet.
   */
  walletPublicKey?: string;

  /**
   * Remaining number of [SignCommand] operations before the wallet will stop signing transactions.
   */
  walletRemainingSignatures: number;

  /**
   * Total number of signed single hashes returned by the card in
   * [SignCommand] responses since card personalization.
   * Sums up array elements within all [SignCommand].
   */
  walletSignedHashes?: number;

  /**
   * Any non-zero value indicates that the card experiences some hardware problems.
   * User should withdraw the value to other blockchain wallet as soon as possible.
   * Non-zero Health tag will also appear in responses of all other commands.
   */
  health?: number;

  /**
   * Whether the card requires issuer’s confirmation of activation.
   * is "true" if the card requires activation
   * is 'false" if the card is activated or does not require activation
   */
  isActivated: boolean;

  /**
   * A random challenge generated by personalisation that should be signed and returned
   * to COS by the issuer to confirm the card has been activated.
   * This field will not be returned if the card is activated.
   */
  activationSeed?: string;

  /**
   * Returned only if [SigningMethod.SignPos] enabling POS transactions is supported by card.
   */
  paymentFlowVersion?: string;

  /**
   * This value can be initialized by terminal and will be increased by COS on execution of every [SignCommand].
   * For example this field can store blockchain “nonce” for quick one-touch transaction on POS terminals.
   * Returned only if [SigningMethod.SignPos]  enabling POS transactions is supported by card.
   */
  userCounter?: number;

  /**
   * This value can be initialized by App (with PIN2 confirmation) and will be increased by COS
   * with the execution of each [SignCommand]. For example this field can store blockchain “nonce”
   * for a quick one-touch transaction on POS terminals. Returned only if [SigningMethod.SignPos].
   */
  userProtectedCounter?: number;

  /**
   * When this value is true, it means that the application is linked to the card,
   * and COS will not enforce security delay if [SignCommand] will be called
   * with [TlvTag.TerminalTransactionSignature] parameter containing a correct signature of raw data
   * to be signed made with [TlvTag.TerminalPublicKey].
   */
  terminalIsLinked: boolean;

  /**
   * Detailed information about card contents. Format is defined by the card issuer.
   * Cards complaint with Tangem Wallet application should have TLV format.
   */
  cardData?: CardData;

  isPin1Default?: boolean;

  isPin2Default?: boolean;
}

export type CreateWalletResponse = {
  /**
   * CID, Unique Tangem card ID number.
   */
  cardId: string;
  /**
   * Current status of the card [1 - Empty, 2 - Loaded, 3- Purged]
   */
  status: CardStatus;
  /**
   * Public key of a newly created blockchain wallet.
   */
  walletPublicKey: string;
};

export type SignResponse = {
  /**
   * CID, Unique Tangem card ID number.
   */
  cardId: string;
  /**
   * signature Signed hashes (array of resulting signatures)
   */
  signature: string | string[];
  /**
   * Remaining number of sign operations before the wallet will stop signing transactions.
   */
  walletRemainingSignatures: number;
  /**
   * Total number of signed single hashes returned by the card in sign command responses.
   */
  walletSignedHashes?: number;
};

export type PurgeWalletResponse = {
  /**
   * CID, Unique Tangem card ID number.
   */
  cardId: string;
  /**
   * Current status of the card [1 - Empty, 2 - Loaded, 3- Purged]
   */
  status: CardStatus;
};

export type SetPinResponse = {
  /**
   * CID, Unique Tangem card ID number.
   */
  cardId: string;
  /**
   * Result status
   */
  status: SetPinStatus;
};

export enum VerifyCardState {
  VerifiedOnline = "VerifiedOnline",
  VerifiedOffline = "VerifiedOffline",
}

export type VerifyCardResponse = {
  /**
   * CID, Unique Tangem card ID number.
   */
  cardId: string;
  /**
   * verification state
   */
  verificationState: "VerifyCardState";
  /**
   * Challenge and salt signed with the wallet private key.
   */
  cardSignature: string;
  /**
   * #### (iOS specific)
   * card publicKey
   */
  cardPublicKey?: string;
  /**
   * Random salt generated by the card
   */
  salt: string;
};

/* Methods options ==================================================================== */
export type NFCStatusResponse = {
  enabled: boolean;
  support: boolean;
};

/**
 * Event's listeneres
 */
export type Events = "NFCStateChange";
export type EventCallback = {
  enabled: boolean;
};

export type InitialMessage = {
  header?: string;
  body?: string;
};

export interface OptionsCommon {
  /**
   * A custom description that shows at the beginning of the NFC session. If nil, default message will be used
   */
  initialMessage?: InitialMessage;
  /**
   * Index to wallet which data should be read.  if not specified - wallet at default index will be read. See `WalletIndex` for more info
   */
  walletIndex?: number;
  /**
   * cardId: CID, Unique Tangem card ID number.
   */
  cardId?: string;
  /**
   * #### (iOS specific)
   * PIN1 string. Hash will be calculated automatically. If nil, the default PIN1 value will be used
   */
  pin1?: string;
  /**
   * #### (iOS specific)
   * PIN2 string. Hash will be calculated automatically. If nil, the default PIN2 value will be used
   */
  pin2?: string;
}

export interface OptionsScanCard {
  /**
   * #### (iOS specific)
   * Verify the card offline and online with Tangem backend. Do not use for developer cards
   */
  onlineVerification?: boolean;
  /**
   * A custom description that shows at the beginning of the NFC session. If nil, default message will be used
   */
  initialMessage?: InitialMessage;
  /**
   * Index to wallet which data should be read.  if not specified - wallet at default index will be read. See `WalletIndex` for more info
   */
  walletIndex?: number;
  /**
   * #### (iOS specific)
   * PIN1 string. Hash will be calculated automatically. If nil, the default PIN1 value will be used
   */
  pin1?: string;
}

export interface OptionsVerifyCard {
  /**
   * cardId: CID, Unique Tangem card ID number.
   */
  cardId?: string;
  /**
   * Verify the card online with Tangem backend. Do not use for developer cards
   */
  online?: boolean;
  /**
   * A custom description that shows at the beginning of the NFC session. If nil, default message will be used
   */
  initialMessage?: InitialMessage;
  /**
   * #### (iOS specific)
   * PIN1 string. Hash will be calculated automatically. If nil, the default PIN1 value will be used
   */
  pin1?: string;
}

export interface OptionsChangePin {
  /**
   * cardId: CID, Unique Tangem card ID number.
   */
  cardId?: string;
  /**
   * A custom description that shows at the beginning of the NFC session. If nil, default message will be used
   */
  initialMessage?: InitialMessage;
  /**
   * PIN1 string. Hash will be calculated automatically. If nil, the default PIN value will be used
   */
  pin?: string;
}

export type RNTangemSdkModule = {
  startSession(): Promise<void>;
  stopSession(): Promise<void>;
  scanCard(options?: OptionsScanCard): Promise<Card>;
  verifyCard(options?: OptionsScanCard): Promise<Card>;
  createWallet(options?: OptionsCommon): Promise<CreateWalletResponse>;
  purgeWallet(options?: OptionsCommon): Promise<PurgeWalletResponse>;
  sign(hashes: string[], options?: OptionsCommon): Promise<SignResponse>;
  changePin1(options?: OptionsChangePin): Promise<SetPinResponse>;
  changePin2(options?: OptionsChangePin): Promise<SetPinResponse>;
  getNFCStatus(): Promise<NFCStatusResponse>;
  on(eventName: Events, handler: (state: EventCallback) => void): void;
  removeListener(
    eventName: Events,
    handler: (state: EventCallback) => void
  ): void;
};
