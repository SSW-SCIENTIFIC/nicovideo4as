package org.mineap.nicovideo4as.analyzer {
    public class DmcInfoAnalyzer {
        private var _result: Object;

        public function DmcInfoAnalyzer() {
            /** do nothing */
        }

        public function analyze(dmcInfo: Object): void {
            this._result = dmcInfo;
        }

        public function get dmcInfo(): Object {
            return this._result;
        }

        public function get isValid(): Boolean {
            return this._result != null;
        }

        public function get isAvailable(): Boolean {
            return this.isValid && this._result.media.delivery.movie.session;
        }

        public function get isHLSAvailable(): Boolean {
            return this.isAvailable && (this._result.media.delivery.movie.session.protocols.indexOf("hls") !== -1);
        }

        public function get apiUrl(): String {
            return this._result.media.delivery.storyboard.session.urls[0].url;
        }

        public function getSession(hls: Boolean = false): Object {
            var session: Object = this._result.media.delivery.movie.session;
            return {
                session: {
                    recipe_id: session.recipeId,
                    content_id: session.contentId,
                    content_type: "movie",
                    content_src_id_sets: [{
                        content_src_ids: [{
                            src_id_to_mux: {
                                video_src_ids: session.videos,
                                audio_src_ids: session.audios
                            }
                        }]
                    }],
                    timing_constraint: "unlimited",
                    keep_method: { heartbeat: { lifetime: session.heartbeatLifetime } },
                    protocol: hls && this.isHLSAvailable ? this.protocolHLS() : this.protocolHTTP(),
                    content_uri: "",
                    session_operation_auth: {
                        session_operation_auth_by_signature: {
                            token: session.token, signature: session.signature
                        }
                    },
                    content_auth: {
                        auth_type: hls ? session.authTypes.hls : session.authTypes.http,
                        content_key_timeout: session.contentKeyTimeout,
                        service_id: "nicovideo",
                        service_user_id: session.serviceUserId
                    },
                    client_info: { player_id: session.playerId },
                    priority: session.priority
                }
            };
        }

        private function protocolHLS(): Object {
            var session: Object = this._result.media.delivery.movie.session;
            var result: Object = {
                name: "http",
                parameters: {
                    http_parameters: {
                        parameters: {
                            hls_parameters: {
                                segment_duration: 6000,
                                transfer_preset: session.transferPresets[0],
                                use_well_known_port: session.urls[0].isWellKnownPort ? "yes" : "no",
                                use_ssl: session.urls[0].isSsl ? "yes" : "no"
                            }
                        }
                    }
                }
            };

            if (this._result.media.delivery.encryption) {
                result.parameters.http_parameters.parameters.hls_parameters.encryption = this._result.encryption;
            }
            return result;
        }

        private function protocolHTTP(): Object {
            var session: Object = this._result.media.delivery.movie.session;
            return {
                name: "http",
                parameters: {
                    http_parameters: {
                        parameters: {
                            http_output_download_parameters: {
                                transfer_preset: session.transferPresets[0],
                                use_well_known_port: session.urls[0].isWellKnownPort ? "yes" : "no",
                                use_ssl: session.urls[0].isSsl ? "yes" : "no"
                            }
                        }
                    }
                }
            };
        }
    }
}
