/*
 * Copyright 2010 Red Hat, Inc.
 * Red Hat licenses this file to you under the Apache License, version
 * 2.0 (the "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *    http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied.  See the License for the specific language governing
 * permissions and limitations under the License.
 */

package org.hornetq.jms.client;

import java.util.List;

import javax.jms.TopicConnectionFactory;

import org.hornetq.api.core.Pair;
import org.hornetq.api.core.TransportConfiguration;


/**
 * A class that represents a TopicConnectionFactory.
 * 
 * @author <a href="mailto:hgao@redhat.com">Howard Gao</a>
 *
 */
public class HornetQTopicConnectionFactory extends HornetQConnectionFactory implements TopicConnectionFactory
{
   private static final long serialVersionUID = 7317051989866548455L;

   public HornetQTopicConnectionFactory(String discoveryAddress, int discoveryPort)
   {
      super(discoveryAddress, discoveryPort);
   }

   public HornetQTopicConnectionFactory(List<Pair<TransportConfiguration, TransportConfiguration>> connectorConfigs)
   {
      super(connectorConfigs);
   }

   public HornetQTopicConnectionFactory(TransportConfiguration connectorConfig,
                                        TransportConfiguration backupConnectorConfig)
   {
      super(connectorConfig, backupConnectorConfig);
   }
}