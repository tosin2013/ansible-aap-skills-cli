# EDA Rulebook Structure Reference

<!-- Last updated: 2026-04-27 -->

Annotated examples of common EDA rulebook patterns for use with
`redhat-cop/eda_configuration`.

---

## Minimal rulebook skeleton

```yaml
---
- name: "<descriptive name>"
  hosts: all
  sources:
    - <event-source-plugin>:
        <plugin-options>
  rules:
    - name: "<rule name>"
      condition: <condition-expression>
      action:
        <action-type>:
          <action-options>
```

---

## Common event source plugins

| Plugin | Use case | Key options |
|:-------|:---------|:------------|
| `ansible.eda.aws_sqs_queue` | AWS SQS messages | `queue_url`, `region`, `delay_seconds` |
| `ansible.eda.kafka` | Kafka topics | `host`, `port`, `topic`, `group_id` |
| `ansible.eda.webhook` | HTTP webhook | `host`, `port` |
| `ansible.eda.alertmanager` | Prometheus alerts | `host`, `port`, `data_alerts_path` |
| `ansible.eda.azure_service_bus` | Azure Service Bus | `conn_str`, `queue_name` |

---

## Common conditions

```yaml
# Simple equality
condition: event.payload.status == "failed"

# Nested key check
condition: event.detail.state == "ERROR"

# Multiple conditions (AND)
condition:
  all:
    - event.payload.severity == "critical"
    - event.payload.environment == "production"

# Multiple conditions (OR)
condition:
  any:
    - event.payload.status == "failed"
    - event.payload.status == "error"
```

---

## Common actions

```yaml
# Run an AAP job template
action:
  run_job_template:
    name: "Remediate Failure"
    organization: "Default"
    job_args:
      extra_vars:
        target_host: "{{ event.payload.host }}"

# Run a playbook directly
action:
  run_playbook:
    name: "remediate.yml"

# Post a debug message
action:
  debug:
    msg: "Event received: {{ event }}"

# Throttle (deduplicate events within a window)
action:
  throttle:
    once_within: 5 minutes
    group_by_attributes:
      - event.payload.host
    action:
      run_job_template:
        name: "Remediate"
        organization: "Default"
```

---

## Full example: auto-remediate failed jobs

```yaml
---
- name: "Auto-remediate failed AAP jobs"
  hosts: all
  sources:
    - ansible.eda.aws_sqs_queue:
        queue_url: "{{ queue_url }}"
        region: "{{ aws_region }}"
        delay_seconds: 10
  rules:
    - name: "Remediate on job failure"
      condition: event.detail.status == "failed"
      action:
        throttle:
          once_within: 10 minutes
          group_by_attributes:
            - event.detail.job_template
          action:
            run_job_template:
              name: "Auto-Remediate"
              organization: "Default"
              job_args:
                extra_vars:
                  failed_job_id: "{{ event.detail.job_id }}"
                  failed_template: "{{ event.detail.job_template }}"
```

---

## Upstream references

- EDA rulebook documentation: https://ansible.readthedocs.io/projects/rulebook/
- eda_configuration collection: https://github.com/redhat-cop/eda_configuration
- EDA event source plugins: https://github.com/ansible/event-driven-ansible
