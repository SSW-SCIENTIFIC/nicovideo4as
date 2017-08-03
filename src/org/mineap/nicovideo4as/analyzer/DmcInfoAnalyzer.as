package org.mineap.nicovideo4as.analyzer {
public class DmcInfoAnalyzer {
    private var _result: Object;

    public function DmcInfoAnalyzer() {
        /** do nothing */
    }

    public function analyze(dmcInfo: Object): void
    {
        this._result = dmcInfo;
    }

    public function get dmcInfo(): Object {
        return this._result;
    }

    public function get isValid(): Boolean
    {
        return this._result != null;
    }

    public function get isAvailable(): Boolean
    {
        return this.isValid && this._result.session_api;
    }

    public function get apiUrl(): String
    {
        return this._result.session_api.urls[0].url;
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
                keep_method: { heartbeat: { lifetime: dmcInfo.heartbeat_lifetime } },
                protocol: {
                    name: dmcInfo.protocols[0],
                    parameters: {
                        http_parameters: {
                            parameters: {
                                http_output_download_parameters: {
                                    use_well_known_port: dmcInfo.urls[0].is_well_known_port ? "yes" : "no",
                                    use_ssl: dmcInfo.urls[0].is_ssl ? "yes" : "no"
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
                    content_key_timeout: dmcInfo.content_key_timeout,
                    service_id: "nicovideo",
                    service_user_id: dmcInfo.service_user_id
                },
                client_info: { player_id: dmcInfo.player_id },
                priority: (isPremium ?
                        (dmcInfo.recipe_id.match(/so[0-9]+$/) ? 1 : 0.8)
                        : (dmcInfo.recipe_id.match(/so[0-9]+$/) ? 0.6 : 0.4)
                )
            }
        };
    }
}
}
