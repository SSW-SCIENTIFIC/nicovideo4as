package org.mineap.nicovideo4as.analyzer {
public class DmcInfoAnalyzer {
    private var _result: Object;

    public function DmcInfoAnalyzer() {
        /** do nothing */
    }

    public function analyze(dmcInfo: String): void
    {
        this._result = JSON.parse(dmcInfo);
    }

    public function get isValid(): Boolean
    {
        return this._result != null;
    }

    public function get apiUrl(): String
    {
        return this._result.session_api.api_urls[0];
    }

    public function getSession(isPremium: Boolean): Object {
        var dmcInfo: Object = this._result.session_api;
        return {
            session: {
                recipe_id: dmcInfo.recipe_id,
                content_id: dmcInfo.content_id,
                content_type: "movie",
                content_src_id_sets: [
                    {
                        content_src_ids: [
                            {
                                src_id_to_mux: {
                                    video_src_ids: dmcInfo.videos,
                                    audio_src_ids: dmcInfo.audios
                                }
                            }
                        ]
                    }
                ],
                timing_constraint: "unlimited",
                keep_method: { heartbeat: { lifetime: 60000 } },
                protocol: {
                    name: dmcInfo.protocols[0],
                    parameters: {
                        http_parameters: {
                            parameters: {
                                http_output_download_parameters: {
                                    use_well_known_port: "no",
                                    use_ssl: "no"
                                }
                            }
                        }
                    }
                },
                content_uri: "",
                session_operation_auth: {
                    session_operation_auth_by_signature: {
                        token: dmcInfo.token,
                        signature: dmcInfo.signature
                    }
                },
                content_auth: {
                    auth_type: dmcInfo.auth_types.http,
                    content_key_timeout: 600000,
                    service_id: "nicovideo",
                    service_user_id: dmcInfo.service_user_id
                },
                client_info: { player_id: dmcInfo.player_id },
                priority: (isPremium ? 0.8 : 0.4)
            }
        };
    }
}
}
