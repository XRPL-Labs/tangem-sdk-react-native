/**
 * Sample React Native App
 *
 * adapted from App.js generated by the following command:
 *
 * react-native init example
 *
 * https://github.com/facebook/react-native
 */

import React, {Component} from 'react';
import {
    SafeAreaView,
    StyleSheet,
    Text,
    View,
    TouchableOpacity,
    Modal,
    ScrollView,
    Alert,
} from 'react-native';

import RNTangemSdk, {Card} from 'tangem-sdk-react-native'

// ==================================== Types ====================================
interface Props {
}

interface State {
    card?: Card
    log?: any
    status?: any
}

// ==================================== App ====================================
export default class App extends Component<Props, State> {
    state = {
        card: undefined,
        log: undefined,
        status: {
            enabled: false,
            support: false,
        },
    } as State;
    private nfcChangeListener: any;

    componentDidMount() {
        // start the session
        RNTangemSdk.startSession({
            attestationMode: 'offline',
        });

        // on nfc state change (Android)
        this.nfcChangeListener = RNTangemSdk.addListener(
            'NFCStateChange',
            ({enabled}) => {
                this.setState({
                    status: {
                        enabled,
                        support: true,
                    },
                });
            },
        );

        // get current nfc status
        RNTangemSdk.getNFCStatus().then(status => {
            this.setState({
                status,
            });
        });
    }

    componentWillUnmount() {
        // remove nfc listener if exists
        if (this.nfcChangeListener) {
            this.nfcChangeListener.remove();
        }
        // stop the session
        RNTangemSdk.stopSession();
    }

    onSuccess = (resp: any) => {
        this.setState({
            log: JSON.stringify(resp, null, '\t'),
        });
    };

    onError = (error: Error) => {
        this.setState({
            log: error.toString(),
        });
    };

    onCardScan = (card: Card) => {
        console.log(JSON.stringify(card));
        this.setState({
            card,
            log: JSON.stringify(card, null, '\t'),
        });
    };

    runCommand = (command: any) => {
        const {card} = this.state;

        if (!card) {
            Alert.alert('Error', 'Please scan the card first!');
            return;
        }

        const {cardId, wallets, supportedCurves} = card;

        const commonOptions = {cardId};

        // apply options
        switch (command) {
            case 'sign':
                Object.assign(commonOptions, {
                    hashes: ['44617461207573656420666f722068617368696e67'],
                });
                if (wallets && wallets.length > 0) {
                    Object.assign(commonOptions, {walletPublicKey: wallets[0].publicKey});
                }
                break;
            case 'purgeWallet':
                if (wallets && wallets.length > 0) {
                    Object.assign(commonOptions, {walletPublicKey: wallets[0].publicKey});
                }
                break;
            case 'createWallet':
                Object.assign(commonOptions, {curve: supportedCurves[0]});
                break;
        }

        // @ts-ignore
        const method = RNTangemSdk[command];

        if (typeof method === 'function') {
            method(commonOptions).then(this.onSuccess).catch(this.onError);
        }
    };

    scanCard = () => {
        RNTangemSdk.scanCard().then(this.onCardScan).catch(this.onError);
    };

    render() {
        const {log, status, card} = this.state;
        return (
            <SafeAreaView style={styles.container}>
                <View style={styles.header}>
                    <Text style={styles.title}>☆RNTangemSdk example☆</Text>
                    <Text style={styles.subTitle}>
                        NFC Supported: {status.support.toString()} | NFC Enabled:{' '}
                        {status.enabled.toString()}
                    </Text>
                    {/* @ts-ignore */}
                    <Text style={styles.subTitle}>Card Id: {card?.cardId || 'CARD IS NOT SCANNED!'}</Text>
                </View>
                <View style={styles.row}>
                    <TouchableOpacity style={styles.button} onPress={this.scanCard}>
                        <Text style={styles.buttonText}>scanCard</Text>
                    </TouchableOpacity>
                </View>
                <View style={styles.row}>
                    <TouchableOpacity
                        style={styles.button}
                        onPress={this.runCommand.bind(null, 'sign')}>
                        <Text style={styles.buttonText}>sign</Text>
                    </TouchableOpacity>
                </View>
                <View style={styles.row}>
                    <TouchableOpacity
                        style={styles.button}
                        onPress={this.runCommand.bind(null, 'createWallet')}>
                        <Text style={styles.buttonText}>createWallet</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                        style={styles.button}
                        onPress={this.runCommand.bind(null, 'purgeWallet')}>
                        <Text style={styles.buttonText}>purgeWallet</Text>
                    </TouchableOpacity>
                </View>
                <View style={styles.row}>
                    <TouchableOpacity
                        style={styles.button}
                        onPress={this.runCommand.bind(null, 'setAccessCode')}>
                        <Text style={styles.buttonText}>setAccessCode</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                        style={styles.button}
                        onPress={this.runCommand.bind(null, 'setPasscode')}>
                        <Text style={styles.buttonText}>setPasscode</Text>
                    </TouchableOpacity>
                </View>
                <View style={styles.row}>
                    <TouchableOpacity
                        style={styles.button}
                        onPress={this.runCommand.bind(null, 'resetUserCodes')}>
                        <Text style={styles.buttonText}>resetUserCodes</Text>
                    </TouchableOpacity>
                </View>

                <Modal
                    animationType="slide"
                    transparent={true}
                    visible={!!log}
                    onRequestClose={() => {
                        this.setState({log: undefined});
                    }}>
                    <View style={styles.modalContainer}>
                        <TouchableOpacity
                            style={[styles.buttonClose]}
                            onPress={() => this.setState({log: undefined})}>
                            <Text style={styles.buttonText}>Close</Text>
                        </TouchableOpacity>
                        <ScrollView
                            style={styles.modalView}
                            contentContainerStyle={{paddingBottom: 50}}>
                            <Text style={styles.logText}>{log}</Text>
                        </ScrollView>
                    </View>
                </Modal>
            </SafeAreaView>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#F5FCFF',
    },
    modalContainer: {
        justifyContent: 'center',
        alignItems: 'center',
        marginTop: 22,
        height: '75%',
        width: '100%',
        position: 'absolute',
        bottom: 0,
    },
    modalView: {
        backgroundColor: '#F5FCFF',
        alignSelf: 'stretch',
        borderColor: '#626984',
        borderWidth: StyleSheet.hairlineWidth,
        padding: 25,
    },
    title: {
        color: 'black',
        fontWeight: 'bold',
        fontSize: 20,
        textAlign: 'center',
        paddingBottom: 30,
    },
    subTitle: {
        color: 'black'
    },
    row: {
        flexDirection: 'row',
        justifyContent: 'center',
        padding: 10,
        marginHorizontal: 10,
    },
    header: {
        paddingVertical: 30,
        justifyContent: 'center',
        alignItems: 'center',
    },
    button: {
        flex: 1,
        margin: 5,
        padding: 10,
        backgroundColor: '#3052FF',
        borderRadius: 10,
        borderWidth: 1,
        borderColor: '#fff',
    },
    buttonText: {
        color: '#fff',
        textAlign: 'center',
        paddingLeft: 10,
        paddingRight: 10,
    },
    buttonClose: {
        width: '100%',
        padding: 15,
        elevation: 2,
        shadowColor: '#000',
        shadowOffset: {
            width: 0,
            height: 1,
        },
        shadowOpacity: 1,
        shadowRadius: 4,
        backgroundColor: '#FF5B5B',
    },
    logText: {
        color: 'black'
    }
});
